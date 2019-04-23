class CommandFactory
  def self.build(type, *args)
    case type
    when :create_alert
      CreateAlertCommand.new(*args)
    when :create_recipient
      CreateRecipientCommand.new(*args)
    when :unsubscribe_recipient
      UnsubscribeRecipientCommand.new(*args)
    end
  end
end