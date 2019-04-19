class CommandFactory
  def self.build(type, params, adapters)
    case type
    when :create_alert
      CreateAlertCommand.new(params, adapters)
    when :create_recipient
      CreateRecipientCommand.new(params, adapters)
    when :unsubscribe_recipient
      UnsubscribeRecipientCommand.new(params, adapters)
    end
  end
end