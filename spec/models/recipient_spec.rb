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
      let(:sms_notifier) { instance_double(Notifiers::SMS, notify: true) }

      before do
        allow(Notifiers::SMS).to receive(:new).and_return(sms_notifier)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(sms_notifier).to have_received(:notify).with(
          to: address,
          message: alert.title
        )
      end
    end

    context 'when the recpient channel is email' do
      let(:channel) { 'email' }
      let(:email_notifier) { instance_double(Notifiers::Email, notify: true) }

      before do
        allow(Notifiers::Email).to receive(:new).and_return(email_notifier)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(email_notifier).to have_received(:notify).with(
          to: address,
          message: alert.title
        )
      end
    end

    context 'when the recpient channel is twitter' do
      let(:channel) { 'twitter' }
      let(:email_notifier) { instance_double(Notifiers::Twitter, notify: true) }

      before do
        allow(Notifiers::Twitter).to receive(:new).and_return(email_notifier)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(email_notifier).to have_received(:notify).with(
          to: address,
          message: alert.title
        )
      end
    end

    context 'when the recpient channel is Facebook Messenger' do
      let(:channel) { 'messenger' }
      let(:email_notifier) { instance_double(Notifiers::Messenger, notify: true) }

      before do
        allow(Notifiers::Messenger).to receive(:new).and_return(email_notifier)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(email_notifier).to have_received(:notify).with(
          to: address,
          message: alert.title
        )
      end
    end

    context 'when the recpient channel is WhatsApp' do
      let(:channel) { 'whatsapp' }
      let(:email_notifier) { instance_double(Notifiers::WhatsApp, notify: true) }

      before do
        allow(Notifiers::WhatsApp).to receive(:new).and_return(email_notifier)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(email_notifier).to have_received(:notify).with(
          to: address,
          message: alert.title
        )
      end
    end

    context 'when the recpient channel is Slack' do
      let(:channel) { 'slack' }
      let(:email_notifier) { instance_double(Notifiers::Slack, notify: true) }

      before do
        allow(Notifiers::Slack).to receive(:new).and_return(email_notifier)

        notify
      end

      it 'notifies the recipient of the alert' do
        expect(email_notifier).to have_received(:notify).with(
          to: address,
          message: alert.title
        )
      end
    end
  end
end
