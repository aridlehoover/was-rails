class CreateRecipientCommand
  attr_reader :params, :adapters

  def initialize(params, adapters)
    @params = params
    @adapters = Array.wrap(adapters).compact
  end

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
