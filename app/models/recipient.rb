class Recipient < ApplicationRecord
  include Notifiable

  validates :channel, presence: true
  validates :address, presence: true

  after_create :notify_last_published_alert

  def notify_last_published_alert
    NotifyRecipientOfLastPublishedAlertJob.perform_later(self)
  end
end
