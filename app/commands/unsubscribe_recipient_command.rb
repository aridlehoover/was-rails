class UnsubscribeRecipientCommand
  attr_reader :params, :adapters

  def initialize(params, adapters)
    @params = params
    @adapters = Array.wrap(adapters).compact
  end

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
