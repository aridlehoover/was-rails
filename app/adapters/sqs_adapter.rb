class SQSAdapter
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def operation_succeeded(_record)
    message.delete
  end

  def operation_failed(record)
  end
end