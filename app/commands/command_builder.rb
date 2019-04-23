class CommandBuilder
  attr_reader :type, :body, :adapters

  def initialize(type, body)
    @type = type
    @body = body
    @adapters = []
  end

  def build
    CommandFactory.build(type, body, [log_adapter, *adapters])
  end

  def sqs(sqs_message)
    adapters << SQSAdapter.new(sqs_message)
    self
  end

  private

  def log_adapter
    LogAdapter.new(type, body, actor: ActorFactory.build(type).to_sym)
  end
end
