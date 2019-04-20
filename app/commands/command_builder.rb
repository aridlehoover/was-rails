class CommandBuilder
  attr_reader :type, :params, :adapters

  def initialize(type, params)
    @type = type
    @params = params
    @adapters = default_adapters
  end

  def sqs(sqs_message)
    @adapters << SQSAdapter.new(sqs_message)
    self
  end

  def build
    CommandFactory.build(type, params, @adapters)
  end

  private

  def default_adapters
    [LogAdapter.new(type, params, actor: ActorFactory.build(type).to_sym)]
  end
end
