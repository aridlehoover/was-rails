if Rails.env.development?
  sqs_connection = SQS::Connection.new(environment: Rails.env, queue_name: ENV['INPUT_QUEUE_NAME'])
  sqs_connection.create_queue
end
