class CommandBuilder
  attr_reader :port, :type, :params

  def initialize(port, type, params)
    @port = port
    @type = type
    @params = params
    @adapters = []
  end

  def log_adapter
    @adapters << LogAdapter.new(type, params, actor: actor)
    self
  end

  def sqs_adapter(sqs_message)
    @adapters << SQSAdapter.new(sqs_message)
    self
  end

  def controller_adapter(controller)
    @adapters << ControllerAdapter.new(controller)
    self
  end

  def build
    CommandFactory.build(type, params, @adapters)
  end

  private

  def actor
    ActorFactory.build(port => type).to_sym
  end
end
