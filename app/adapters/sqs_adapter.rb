class SQSAdapter
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def operation_succeeded(_alert)
    message.delete
  end

  def operation_failed(alert)
  end
end
