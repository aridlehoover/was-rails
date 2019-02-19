require_relative 'config/application'
require_relative 'lib/sqs/connection'

Rails.application.initialize!
Rails.application.eager_load!

environment = Rails.env
sqs_connection = SQS::Connection.new(
  environment: environment,
  queue_name: ENV['INPUT_QUEUE_NAME']
)

Shoryuken.sqs_client = sqs_connection.client

if environment.development?
  sqs_connection.create_queue
  Shoryuken.configure_server { |config| config.sqs_client = sqs_connection.client }
end

# bundle exec shoryuken -q was-input.us-east-1.fifo -r ./worker
