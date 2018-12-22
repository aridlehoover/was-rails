class ScheduledWorker
  include Sidekiq::Worker

  def perform
    return if message.blank?

    case message_type
    when 'create_alert'
      CreateAlertJob.perform_later(message_body)
    when 'create_recipient'
      CreateRecipientJob.perform_later(message_body)
    when 'unsubscribe_recipient'
      UnsubscribeRecipientJob.perform_later(message_body)
    end
  end

  private

  def message_type
    message_body[:type]
  end

  def message_body
    JSON.parse(message.body).with_indifferent_access
  end

  def message
    @message ||= connection.receive_message
  end

  def connection
    @connection ||= SQS::Connection.new(environment: Rails.env, queue_name: ENV['INPUT_QUEUE_NAME'])
  end
end
