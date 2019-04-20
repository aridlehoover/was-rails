class CommandBuilder
  attr_reader :type, :params, :port, :adapters

  def initialize(type, params)
    @type = type
    @params = params
    @port = nil
    @adapters = []
  end

  def sqs(sqs_message)
    @port = :sqs
    @adapters << SQSAdapter.new(sqs_message)
    self
  end

  def controller(controller)
    @port = :controller
    @adapters << ControllerAdapter.new(controller)
    self
  end

  def build
    CommandFactory.build(type, params, [log_adapter, *adapters])
  end

  private

  def log_adapter
    LogAdapter.new(type, params, actor: ActorFactory.build(actor_key).to_sym)
  end

  def actor_key
    { port: port, command: type }
  end
end
