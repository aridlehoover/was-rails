class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    @sqs_message = sqs_message
    @body = body

    command.perform
  end

  private

  def params
    @params ||= @body.except('type')
  end

  def type
    @type ||= @body['type']&.to_sym
  end

  def command
    log_adapter = LogAdapter.new(type, params, actor: ActorFactory.build(type).to_sym)
    sqs_adapter = SQSAdapter.new(@sqs_message)

    CommandFactory.build(type, params, [log_adapter, sqs_adapter])
  end
end
