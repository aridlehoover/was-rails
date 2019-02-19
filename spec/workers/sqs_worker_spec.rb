require 'rails_helper'

describe SQSWorker do
  subject(:worker) { described_class.new }

  describe '#perform' do
    subject(:perform) { worker.perform(sqs_message, body) }

    let(:sqs_message) { instance_double('sqs_message', delete: true) }
    let(:body) { { 'type' => type } }
    let(:type) { 'type' }

    it 'deletes the sqs_message' do
      perform

      expect(sqs_message).to have_received(:delete)
    end

    context 'when the type is create_alert' do
      let(:type) { 'create_alert' }

      before do
        allow(CreateAlertJob).to receive(:perform_later)

        perform
      end

      it 'enqueues a create alert job' do
        expect(CreateAlertJob).to have_received(:perform_later).with(body)
      end
    end

    context 'when the type is create_recipient' do
      let(:type) { 'create_recipient' }

      before do
        allow(CreateRecipientJob).to receive(:perform_later)

        perform
      end

      it 'enqueues a create recipient job' do
        expect(CreateRecipientJob).to have_received(:perform_later).with(body)
      end
    end

    context 'when the type is unsubscribe_recipient' do
      let(:type) { 'unsubscribe_recipient' }

      before do
        allow(UnsubscribeRecipientJob).to receive(:perform_later)

        perform
      end

      it 'enqueues a unsubscribe recipient job' do
        expect(UnsubscribeRecipientJob).to have_received(:perform_later).with(body)
      end
    end
  end
end
