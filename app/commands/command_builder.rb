class CommandBuilder
  attr_reader :type, :params

  def initialize(type, params)
    @type = type
    @params = params
    @adapters = []
  end

  def log_adapter
    @adapters << LogAdapter.new(type, params, actor: ActorFactory.build(type).to_sym)
    self
  end

  def sqs_adapter(sqs_message)
    @adapters << SQSAdapter.new(sqs_message)
    self
  end

  def build
    CommandFactory.build(type, params, @adapters)
  end
end
