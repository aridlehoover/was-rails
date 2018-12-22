class UnsubscribeRecipientJob < ApplicationJob
  ALLOWED_ATTRIBUTES = ['channel', 'address'].freeze

  def perform(recipient_attributes)
    Recipient.find_by(recipient_attributes.slice(*ALLOWED_ATTRIBUTES))&.destroy
  end
end
