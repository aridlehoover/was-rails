class SQSAdapter
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def succeeded(_record)
    message.delete
  end

  def failed(record)
  end
end
