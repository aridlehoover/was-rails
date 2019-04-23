class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    type = body.delete('type').to_sym

    log_adapter = LogAdapter.new(type, body, actor: ActorFactory.build(type).to_sym)
    sqs_adapter = SQSAdapter.new(sqs_message)

    CommandFactory.build(type, body, [log_adapter, sqs_adapter]).perform
  end
end
