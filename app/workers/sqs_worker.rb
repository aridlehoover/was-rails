class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    @sqs_message = sqs_message
    @body = body

    command.perform
  end

  private

  def type
    @body['type'].to_sym
  end

  def params
    @body.except('type')
  end

  def command
    log_adapter = LogAdapter.new(type, params, actor: actor)
    sqs_adapter = SQSAdapter.new(@sqs_message)

    CommandFactory.build(type, params, [log_adapter, sqs_adapter])
  end

  def actor
    case type
    when :create_alert
      :telemetry
    when :create_recipient
      :telecom
    when :unsubscribe_recipient
      :telecom
    end
  end
end
