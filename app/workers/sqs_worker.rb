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
    alert = Alert.create(params)
    if alert.persisted?
      ExternalLogger.log_and_increment(
        action: :create_alert,
        actor: :telemetry,
        status: :succeeded,
        params: params
      )
      @sqs_message.delete
    else
      ExternalLogger.log_and_increment(
        action: :create_alert,
        actor: :telemetry,
        status: :failed,
        params: params,
        errors: alert.errors.messages
      )
    end
  end

  def create_recipient
    recipient = Recipient.create(params)
    if recipient.persisted?
      ExternalLogger.log_and_increment(
        action: :create_recipient,
        actor: :telecom,
        status: :succeeded,
        params: params
      )
      @sqs_message.delete
    else
      ExternalLogger.log_and_increment(
        action: :create_recipient,
        actor: :telecom,
        status: :failed,
        params: params,
        errors: recipient.errors.messages
      )
    end
  end

  def unsubscribe_recipient
    recipient = Recipient.find_by(params)

    if recipient.present?
      recipient.destroy
      ExternalLogger.log_and_increment(
        action: :unsubscribe_recipient,
        actor: :telecom,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.log_and_increment(
        action: :unsubscribe_recipient,
        actor: :telecom,
        status: :failed,
        params: params
      )
    end

    @sqs_message.delete
  end
end
