class Recipient < ApplicationRecord
  NOTIFIERS = {
    sms: Notifiers::SMS,
    email: Notifiers::Email,
    twitter: Notifiers::Twitter,
    messenger: Notifiers::Messenger,
    whatsapp: Notifiers::WhatsApp,
    slack: Notifiers::Slack
  }.freeze

  validates :channel, presence: true
  validates :address, presence: true

  after_create :notify_last_published_alert

  def notify(alert)
    notifier.new.notify(to: address, message: alert.title)
  end

  def notify_last_published_alert
    NotifyRecipientOfLastPublishedAlertJob.perform_later(self)
  end

  private

  def notifier
    NOTIFIERS[channel.to_sym]
  end
end
