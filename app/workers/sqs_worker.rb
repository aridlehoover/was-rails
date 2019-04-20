class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    type = body.delete('type').to_sym

    CommandBuilder.new(type, body)
      .sqs(sqs_message)
      .build
      .perform
  end
end
