class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    case body['type']
    when 'create_alert'
      alert = Alert.create(body.slice(*Alert::ALLOWED_ATTRIBUTES))
      if alert.persisted?
        WASLogger.json(action: :create_alert, actor: :telemetry, status: :succeeded, params: body)
      else
        WASLogger.json(action: :create_alert, actor: :telemetry, status: :failed, params: body, errors: alert.errors.messages)
      end
    when 'create_recipient'
      Recipient.create(body.slice(*Recipient::ALLOWED_ATTRIBUTES))
    when 'unsubscribe_recipient'
      Recipient.find_by(body.slice(*Recipient::ALLOWED_ATTRIBUTES))&.destroy
    end

    sqs_message.delete
  end
end
