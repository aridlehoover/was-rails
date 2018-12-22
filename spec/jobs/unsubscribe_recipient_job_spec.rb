require 'rails_helper'

describe UnsubscribeRecipientJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(recipient_attributes) }

    let(:recipient_attributes) do
      {
        'channel' => channel,
        'address' => address
      }
    end

    let(:channel) { 'channel' }
    let(:address) { 'address' }
    let(:recipient) { nil }

    before do
      allow(Recipient).to receive(:find_by).and_return(recipient)

      perform
    end

    it 'finds a recipient from the channel and address' do
      expect(Recipient).to have_received(:find_by).with(recipient_attributes)
    end

    context 'when a recipient is NOT found' do
      let(:recipient) { nil }

      it 'does not raise an exception' do
        expect { perform }.not_to raise_error
      end
    end

    context 'when a recipient is found' do
      let(:recipient) { instance_double(Recipient, destroy: true) }

      it 'destroys the recipient record' do
        expect(recipient).to have_received(:destroy)
      end
    end
  end
end
