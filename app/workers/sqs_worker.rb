class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    type = body.delete('type').to_sym

    log_adapter = LogAdapter.new(type, body, actor: actor(type))
    sqs_adapter = SQSAdapter.new(sqs_message)

    CommandFactory.build(type, body, [log_adapter, sqs_adapter]).perform
  end

  private

  def actor(type)
    case type
    when :create_alert
      :telemetry
    else
      :telecom
    end
  end
end
