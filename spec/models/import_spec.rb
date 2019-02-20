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
    let(:recipient1) { instance_double(Recipient, persisted?: persisted?) }
    let(:recipient2) { instance_double(Recipient, persisted?: persisted?) }
    let(:persisted?) { true }

    before do
      allow(import).to receive(:file).and_return(file)
      allow(CSV).to receive(:parse).and_return(csv_rows)
      allow(Recipient).to receive(:create).and_return(recipient1, recipient2)
      allow(WASLogger).to receive(:json)
    end

    context 'when ALL recipients are successfully created' do
      let(:persisted?) { true }

      before { import_recipients }

      it 'logs success' do
        expect(WASLogger)
          .to have_received(:json)
          .with(action: :import_recipients, actor: :administrator, status: :succeeded, params: import.attributes)
      end
    end

    context 'when SOME recipients are NOT created' do
      let(:persisted?) { false }
      let(:recipient_attributes) { { channel: nil } }

      before do
        allow(recipient1).to receive(:attributes).and_return(recipient_attributes)
        allow(recipient2).to receive(:attributes).and_return(recipient_attributes)

        import_recipients
      end

      it 'logs failure' do
        expect(WASLogger)
          .to have_received(:json)
          .with(
            action: :import_recipients,
            actor: :administrator,
            status: :failed,
            params: import.attributes,
            failed_recipients: [recipient1.attributes, recipient2.attributes]
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
