class UnsubscribeRecipientCommand < Command
  corresponds_to :unsubscribe_recipient

  def perform
    recipient = Recipient.find_by(params)

    if recipient.present?
      recipient.destroy

      adapters.each { |adapter| adapter.succeeded(recipient) }
    else
      adapters.each(&:not_found)
    end

    recipient
  end
end
