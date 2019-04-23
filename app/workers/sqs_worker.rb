class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    @sqs_message = sqs_message
    @body = body

    case body['type']
    when 'create_alert'
      create_alert
    when 'create_recipient'
      create_recipient
    when 'unsubscribe_recipient'
      unsubscribe_recipient
    end
  end

  private

  def params
    @params ||= @body.except('type')
  end

  def create_alert
    log_adapter = LogAdapter.new(:create_alert, params, actor: :telemetry)
    sqs_adapter = SQSAdapter.new(@sqs_message)

    CreateAlertCommand.new(params, [log_adapter, sqs_adapter]).perform
  end

  def create_recipient
    log_adapter = LogAdapter.new(:create_recipient, params, actor: :telecom)
    sqs_adapter = SQSAdapter.new(@sqs_message)

    CreateRecipientCommand.new(params, [log_adapter, sqs_adapter]).perform
  end

  def unsubscribe_recipient
    log_adapter = LogAdapter.new(:unsubscribe_recipient, params, actor: :telecom)
    sqs_adapter = SQSAdapter.new(@sqs_message)

    UnsubscribeRecipientCommand.new(params, [log_adapter, sqs_adapter]).perform
  end
end
