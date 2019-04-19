class SQSWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['INPUT_QUEUE_NAME'], body_parser: :json

  def perform(sqs_message, body)
    @sqs_message = sqs_message
    @body = body

    command.perform
  end

  private

  def params
    @params ||= @body.except('type')
  end

  def type
    @type ||= @body['type']&.to_sym
  end

  def command
    CommandBuilder.new(type, params)
      .log_adapter
      .sqs_adapter(@sqs_message)
      .build
  end
end
