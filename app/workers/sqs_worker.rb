class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    case body['type']
    when 'create_alert'
      alert = Alert.create(body.slice(*Alert::ALLOWED_ATTRIBUTES))
      if alert.persisted?
        sqs_message.delete
        WASLogger.json(action: :create_alert, actor: :telemetry, status: :succeeded, params: body)
      else
        WASLogger.json(action: :create_alert, actor: :telemetry, status: :failed, params: body, errors: alert.errors.messages)
      end
    when 'create_recipient'
      recipient = Recipient.create(body.slice(*Recipient::ALLOWED_ATTRIBUTES))
      if recipient.persisted?
        sqs_message.delete
        WASLogger.json(action: :create_recipient, actor: :telecom, status: :succeeded, params: body)
      else
        WASLogger.json(action: :create_recipient, actor: :telecom, status: :failed, params: body, errors: recipient.errors.messages)
      end
    when 'unsubscribe_recipient'
      recipient = Recipient.find_by(body.slice(*Recipient::ALLOWED_ATTRIBUTES))

      if recipient.present?
        recipient.destroy
        WASLogger.json(action: :unsubscribe_recipient, actor: :telecom, status: :succeeded, params: body)
      else
        WASLogger.json(action: :unsubscribe_recipient, actor: :telecom, status: :failed, params: body)
      end

      sqs_message.delete
    end
  end
end
