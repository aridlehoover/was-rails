class CreateRecipientCommand < Command
  corresponds_to :create_recipient

  def perform
    recipient = Recipient.create(params)

    if recipient.persisted?
      adapters.each { |adapter| adapter.succeeded(recipient) }
    else
      adapters.each { |adapter| adapter.failed(recipient) }
    end

    recipient
  end
end
