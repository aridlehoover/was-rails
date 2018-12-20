require 'rails_helper'

describe Recipient, type: :model do
  subject(:recipient) { described_class.new(channel: channel, address: address) }

  let(:channel) { 'channel' }
  let(:address) { 'address' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:channel) }
    it { is_expected.to validate_presence_of(:address) }
  end

  describe 'after create' do
    let(:published_alerts) { [first_published_alert, last_published_alert] }
    let(:first_published_alert) { instance_double(Alert) }
    let(:last_published_alert) { instance_double(Alert) }

    before do
      allow(Alert).to receive(:published).and_return(published_alerts)
      allow(NotifyRecipientOfLastPublishedAlertJob).to receive(:perform_later)

      recipient.save
    end

    it 'notifies the receipient of the latest published alert' do
      expect(NotifyRecipientOfLastPublishedAlertJob).to have_received(:perform_later).with(recipient)
    end
  end

  describe '#notify' do
    subject(:notify) { recipient.notify(alert) }

    let(:alert) { instance_double(Alert, title: 'Title') }

    context 'when the recpient channel is sms' do
      let(:channel) { 'sms' }
      let(:twilio_client) { instance_double(Twilio::REST::Client, api: api) }
      let(:api) { instance_double('api', account: account) }
      let(:account) { instance_double('account', messages: messages) }
      let(:messages) { instance_double('messages', create: true) }
      let(:twilio_account_sid) { 'twilio_account_sid' }
      let(:twilio_auth_token) { 'twilio_auth_token' }

      before do
        allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
        allow(ENV).to receive(:[]).with('TWILIO_ACCOUNT_SID').and_return(twilio_account_sid)
        allow(ENV).to receive(:[]).with('TWILIO_AUTH_TOKEN').and_return(twilio_auth_token)

        notify
      end

      it 'instantiates Twilio REST client with correct values' do
        expect(Twilio::REST::Client).to have_received(:new).with(twilio_account_sid, twilio_auth_token)
      end

      it 'notifies the receipient of the alert' do
        expect(messages).to have_received(:create).with(from: '+14156897774', to: address, body: alert.title)
      end
    end

    context 'when the recpient channel is email' do
      let(:channel) { 'email' }
      let(:sendgrid_api_key) { 'sendgrid_api_key' }

      before do
        allow(RestClient).to receive(:post)
        allow(ENV).to receive(:[]).with('SENDGRID_API_KEY').and_return(sendgrid_api_key)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(RestClient).to have_received(:post).with(
          'https://api.sendgrid.com/v3/mail/send',
          {
            to: [{ email: address }],
            subject: 'Alert',
            content: [{ value: alert.title, type: 'text/plain' }]
          },
          'Authorization' => "Bearer #{sendgrid_api_key}"
        )
      end
    end

    context 'when the recpient channel is twitter' do
      let(:channel) { 'twitter' }
      let(:twitter_client) { instance_double(Twitter::REST::Client, update: true) }

      before do
        allow(Twitter::REST::Client).to receive(:new).and_return(twitter_client)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(twitter_client).to have_received(:update).with("#{address} - #{alert.title}")
      end
    end

    context 'when the recpient channel is Facebook Messenger' do
      let(:channel) { 'messenger' }
      let(:facebook_access_token) { 'facebook_access_token' }

      before do
        allow(Facebook::Messenger::Bot).to receive(:deliver)
        allow(ENV).to receive(:[]).with('FACEBOOK_ACCESS_TOKEN').and_return(facebook_access_token)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(Facebook::Messenger::Bot).to have_received(:deliver).with(
          {
            recipient: { id: address },
            message: { text: alert.title },
            message_type: Facebook::Messenger::Bot::MessagingType::UPDATE
          },
          access_token: facebook_access_token
        )
      end
    end

    context 'when the recpient channel is WhatsApp' do
      let(:channel) { 'whatsapp' }
      let(:whats_api) { instance_double(Whats::Api, send_message: true) }

      before do
        allow(Whats::Api).to receive(:new).and_return(whats_api)

        notify
      end

      it 'notifies the receipient of the alert' do
        expect(whats_api).to have_received(:send_message).with(address, alert.title)
      end
    end

    context 'when the recpient channel is Slack' do
      let(:channel) { 'slack' }
      let(:slack_notifier) { instance_double(Slack::Notifier, ping: true) }

      before do
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier)

        notify
      end

      it 'instantiates a slack notifier with the correct attributes' do
        expect(Slack::Notifier).to have_received(:new).with(address, channel: "#weather-alerts", username: "was-bot")
      end

      it 'notifies the receipient of the alert' do
        expect(slack_notifier).to have_received(:ping).with(alert.title)
      end
    end
  end
end
