require 'securerandom'
require 'aws-sdk-sqs'
require_relative './client_attributes_builder'

module SQS
  class Connection
    attr_reader :environment, :queue_name, :attributes_builder

    def initialize(environment:, queue_name:, attributes_builder: ClientAttributesBuilder)
      @environment = environment
      @queue_name = queue_name
      @attributes_builder = attributes_builder
    end

    def client
      @client ||= Aws::SQS::Client.new(client_attributes)
    end

    def send_message(message_body:, message_group_id:, message_deduplication_id: nil)
      client.send_message(
        queue_url: queue_url,
        message_group_id: message_group_id,
        message_deduplication_id: message_deduplication_id || SecureRandom.uuid,
        message_body: message_body
      )
    end

    def receive_message
      receive_message_response = client.receive_message(queue_url: queue_url)
      receive_message_response.messages.first
    end

    def create_queue
      client.create_queue(queue_name: queue_name, attributes: { "FifoQueue" => "true" })
    end

    private

    def client_attributes
      @client_attributes ||= attributes_builder.build(environment)
    end

    def queue_url
      @queue_url ||= client.get_queue_url(queue_name: queue_name).queue_url
    end
  end
end
