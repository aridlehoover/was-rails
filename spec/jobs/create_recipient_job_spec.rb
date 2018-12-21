require 'rails_helper'

describe CreateRecipientJob, type: :job do
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

    before do
      allow(Recipient).to receive(:create)

      perform
    end

    it 'creates an recipient with the provided recipient attributes' do
      expect(Recipient).to have_received(:create).with(recipient_attributes)
    end
  end
end
