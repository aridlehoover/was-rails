class CreateRecipientJob < ApplicationJob
  ALLOWED_ATTRIBUTES = ['channel', 'address'].freeze

  def perform(recipient_attributes)
    Recipient.create(recipient_attributes.slice(*ALLOWED_ATTRIBUTES))
  end
end
