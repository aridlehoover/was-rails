require 'rails_helper'

describe Recipient, type: :model do
  subject(:recipient) { described_class.new(channel: 'channel', address: 'address') }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:channel) }
    it { is_expected.to validate_presence_of(:address) }
  end

  describe '#notify' do
    subject(:notify) { recipient.notify(alert) }

    let(:alert) { instance_double(Alert, title: 'Title') }
    let(:sms_client) { instance_double(SMSClient, send_message: true) }

    before do
      allow(SMSClient).to receive(:new).and_return(sms_client)

      notify
    end

    it 'notifies the recipient of an alert' do
      expect(sms_client).to have_received(:send_message).with(
        from: '000-000-0000',
        to: recipient.address,
        message: alert.title
      )
    end
  end
end
