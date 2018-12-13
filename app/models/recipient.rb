class Recipient < ApplicationRecord
  validates :channel, presence: true
  validates :address, presence: true

  after_create :notify_last_published_alert

  def notify(alert)
    SMSClient.new.send_message(from: '000-000-0000', to: address, message: alert.title)
  end

  def notify_last_published_alert
    NotifyRecipientOfLastPublishedAlertJob.perform_later(self)
  end
end
