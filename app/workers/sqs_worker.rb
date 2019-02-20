class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    case body['type']
    when 'create_alert'
      Alert.create(body.slice(*Alert::ALLOWED_ATTRIBUTES))
    when 'create_recipient'
      Recipient.create(body.slice(*Recipient::ALLOWED_ATTRIBUTES))
    when 'unsubscribe_recipient'
      UnsubscribeRecipientJob.perform_later(body)
    end

    sqs_message.delete
  end
end
