require 'rails_helper'

describe ImportRecipientsJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(import) }

    let(:import) { instance_double(Import, import_type: import_type, file: file) }
    let(:import_type) { 'recipients' }
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

    before do
      allow(CSV).to receive(:parse).and_return(csv_rows)
      allow(Recipient).to receive(:create)

      perform
    end

    context 'when import type is NOT receipient' do
      let(:import_type) { 'not recipient' }

      it 'does NOT process create recpients' do
        expect(Recipient).not_to have_received(:create)
      end
    end

    context 'when import type is recipients' do
      let(:import_type) { 'recipients' }

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
