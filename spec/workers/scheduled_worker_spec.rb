require 'rails_helper'

describe ScheduledWorker do
  subject(:worker) { described_class.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    let(:input_queue_name) { 'input_queue_name' }
    let(:environment) { 'environment' }
    let(:sqs_connection) { instance_double(SQS::Connection, receive_message: message) }
    let(:message) { instance_double(Aws::SQS::Types::Message, body: body) }
    let(:body) { {}.to_json }

    before do
      allow(ENV).to receive(:[]).with('INPUT_QUEUE_NAME').and_return(input_queue_name)
      allow(Rails).to receive(:env).and_return(environment)
      allow(SQS::Connection).to receive(:new).and_return(sqs_connection)
      allow(CreateAlertJob).to receive(:perform_later)

      perform
    end

    it 'instantiates an SQS connection' do
      expect(SQS::Connection).to have_received(:new).with(environment: environment, queue_name: input_queue_name)
    end

    it 'pulls a message from the input queue' do
      expect(sqs_connection).to have_received(:receive_message)
    end

    context 'when the message contains an alert' do
      let(:body) { { type: 'alert' }.to_json }

      it 'enqueues a CreateAlertJob with the correct data' do
        expect(CreateAlertJob).to have_received(:perform_later).with(JSON.parse(body))
      end
    end
  end
end
