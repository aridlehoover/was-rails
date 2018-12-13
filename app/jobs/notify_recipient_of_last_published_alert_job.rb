class NotifyRecipientOfLastPublishedAlertJob < ApplicationJob
  queue_as :default

  def perform(recipient)
    recipient.notify(Alert.published.last)
  end
end
