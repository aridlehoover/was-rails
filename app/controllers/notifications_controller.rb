class NotificationsController < ApplicationController
  def create
    case notification_type
    when :alert
      alert = Alert.find_by(id: id)
      NotifyAllRecipientsJob.perform_later(alert) if alert.present?
    when :recipient
      recipient = Recipient.find_by(id: id)
      NotifyRecipientOfLastPublishedAlertJob.perform_later(recipient) if recipient.present?
    end
  end

  private

  def id
    notification_params[:id]
  end

  def notification_type
    notification_params[:notification_type].to_sym
  end

  def notification_params
    params.require(:notification).permit(:id, :notification_type)
  end
end
