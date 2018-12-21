class ScheduledWorker
  include Sidekiq::Worker

  def perform
    message = connection.receive_message
    CreateAlertJob.perform_later(JSON.parse(message.body))
  end

  private

  def connection
    SQS::Connection.new(
      environment: Rails.env,
      queue_name: ENV['INPUT_QUEUE_NAME']
    )
  end
end
