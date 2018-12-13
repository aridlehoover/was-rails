class NotifyAllRecipientsJob < ApplicationJob
  queue_as :default

  def perform(alert)
    Recipient.all.each { |recipient| recipient.notify(alert) }
  end
end
