require 'rails_helper'

describe Import, type: :model do
  subject(:import) { described_class.new(import_attributes) }

  let(:import_attributes) { { import_type: import_type } }
  let(:import_type) { 'recipients' }

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:import_type).in_array(Import::VALID_IMPORT_TYPES) }
  end

  describe 'after create' do
    before do
      allow(ImportRecipientsJob).to receive(:perform_later)

      import.save
    end

    it 'notifies the receipient of the latest published alert' do
      expect(ImportRecipientsJob).to have_received(:perform_later).with(import)
    end
  end

  describe '#import_recipients' do
    subject(:import_recipients) { import.import_recipients }

    let(:file) { instance_double('file', content_type: content_type, download: content) }
    let(:content_type) { 'text/csv' }
    let(:content) { instance_double('file_contents') }
    let(:csv_rows) do
      [
        ['channel', 'address'],
        ['SMS', '123-456-7890'],
        ['Email', 'test@example.com']
      ]
    end
    let(:recipient1) { instance_double(Recipient, persisted?: persisted?, attributes: recipient1_attributes) }
    let(:recipient2) { instance_double(Recipient, persisted?: persisted?, attributes: recipient2_attributes) }
    let(:persisted?) { true }
    let(:recipient1_attributes) { { channel: 'SMS', address: '123-456-7890' } }
    let(:recipient2_attributes) { { channel: 'Email', address: 'test@example.com' } }

    before do
      allow(import).to receive(:file).and_return(file)
      allow(CSV).to receive(:parse).and_return(csv_rows)
      allow(Recipient).to receive(:create).and_return(recipient1, recipient2)
      allow(WASLogger).to receive(:json)
    end

    context 'when ALL recipients are successfully created' do
      let(:persisted?) { true }

      before { import_recipients }

      it 'logs success for the import' do
        expect(WASLogger)
          .to have_received(:json)
          .with(action: :import_recipients, actor: :administrator, status: :succeeded, params: import.attributes)
      end

      it 'logs success for each recipient' do
        expect(WASLogger)
          .to have_received(:json)
          .with(action: :create_recipient, actor: :administrator, status: :succeeded, params: recipient1_attributes)
        expect(WASLogger)
          .to have_received(:json)
          .with(action: :create_recipient, actor: :administrator, status: :succeeded, params: recipient2_attributes)
      end
    end

    context 'when SOME recipients are NOT created' do
      let(:recipient1) { instance_double(Recipient, persisted?: persisted?, attributes: recipient1_attributes, errors: errors) }
      let(:errors) { instance_double('errors', messages: error_messages) }
      let(:error_messages) { instance_double('error_messages') }

      before do
        allow(recipient1).to receive(:persisted?).and_return(false)

        import_recipients
      end

      it 'logs failure for the import' do
        expect(WASLogger)
          .to have_received(:json)
          .with(
            action: :import_recipients,
            actor: :administrator,
            status: :failed,
            params: import.attributes,
            failed_recipients: [recipient1.attributes]
          )
      end

      it 'logs failure for each failed recipient' do
        expect(WASLogger)
          .to have_received(:json)
          .with(
            action: :create_recipient,
            actor: :administrator,
            status: :failed,
            params: recipient1.attributes,
            errors: error_messages
          )
      end
    end

    context 'when import type is NOT receipient' do
      let(:import_type) { 'not recipient' }

      before { import_recipients }

      it 'does NOT process create recpients' do
        expect(Recipient).not_to have_received(:create)
      end
    end

    context 'when import type is recipients' do
      let(:import_type) { 'recipients' }

      before { import_recipients }

      context 'and the file type is NOT CSV' do
        let(:content_type) { 'image/png' }

        it 'does NOT process create recpients' do
          expect(Recipient).not_to have_received(:create)
        end
      end

      context 'and the file type is CSV' do
        let(:content_type) { 'text/csv' }

        it 'assumes the first row contains headers' do
          expect(Recipient).not_to have_received(:create).with(channel: 'channel', address: 'address')
        end

        it 'creates a recipient record for each row in the file' do
          expect(Recipient).to have_received(:create).with(channel: 'sms', address: '123-456-7890')
          expect(Recipient).to have_received(:create).with(channel: 'email', address: 'test@example.com')
        end
      end
    end
  end
end
