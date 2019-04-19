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
    case type
    when :create_alert
      CreateAlertCommand.new(params, [log_adapter(:telemetry), sqs_adapter])
    when :create_recipient
      CreateRecipientCommand.new(params, [log_adapter(:telecom), sqs_adapter])
    when :unsubscribe_recipient
      UnsubscribeRecipientCommand.new(params, [log_adapter(:telecom), sqs_adapter])
    end
  end

  def sqs_adapter
    SQSAdapter.new(@sqs_message)
  end

  def log_adapter(actor)
    LogAdapter.new(type, params, actor: actor)
  end
end
