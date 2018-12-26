require 'rails_helper'

describe NotificationsController, type: :controller do
  let(:valid_attributes) { { id: id, notification_type: notification_type } }
  let(:id) { 42 }
  let(:notification_type) { 'notification_type' }
  let(:valid_session) { {} }

  describe 'POST #create' do
    subject(:create) { post :create, params: { notification: valid_attributes }, session: valid_session }

    context 'with valid params' do
      context 'when the notification type is an alert' do
        let(:notification_type) { 'alert' }
        let(:alert) { instance_double(Alert, present?: true) }

        before do
          allow(Alert).to receive(:find_by).and_return(alert)
          allow(NotifyAllRecipientsJob).to receive(:perform_later)

          create
        end

        it 'notifies all recipients of the alert' do
          expect(NotifyAllRecipientsJob).to have_received(:perform_later).with(alert)
        end
      end

      context 'when the notification type is a recipient' do
        let(:notification_type) { 'recipient' }
        let(:recipient) { instance_double(Recipient, present?: true) }

        before do
          allow(Recipient).to receive(:find_by).and_return(recipient)
          allow(NotifyRecipientOfLastPublishedAlertJob).to receive(:perform_later)

          create
        end

        it 'notifies recipient of the latest published alert' do
          expect(NotifyRecipientOfLastPublishedAlertJob).to have_received(:perform_later).with(recipient)
        end
      end
    end
  end
end
