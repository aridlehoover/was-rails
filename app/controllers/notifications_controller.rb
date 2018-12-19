class NotificationsController < ApplicationController
  NOTIFICATION_JOBS = {
    alert: NotifyAllRecipientsJob,
    recipient: NotifyRecipientOfLastPublishedAlertJob
  }.freeze

  def create
    job.perform_later(record) if record.present? && job.present?
  end

  private

  def job
    NOTIFICATION_JOBS[notification_type.to_sym]
  end

  def record
    notification_type.camelize.constantize.find_by(id: id) if notification_type.present?
  end

  def notification_params
    params.require(:notification).permit(:id, :notification_type)
  end

  def id
    notification_params[:id]
  end

  def notification_type
    notification_params[:notification_type]
  end
end
