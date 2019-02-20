require 'rails_helper'

describe SQSWorker do
  subject(:worker) { described_class.new }

  describe '#perform' do
    subject(:perform) { worker.perform(sqs_message, body) }

    let(:sqs_message) { instance_double('sqs_message', delete: true) }
    let(:body) { { 'type' => type }.merge(attributes) }
    let(:type) { 'type' }
    let(:attributes) { {} }

    it 'deletes the sqs_message' do
      perform

      expect(sqs_message).to have_received(:delete)
    end

    context 'when the type is create_alert' do
      let(:type) { 'create_alert' }
      let(:attributes) do
        {
          'uuid' => 'uuid',
          'title' => 'title',
          'location' => 'location',
          'publish_at' => '2019-01-01 00:00:00'
        }
      end

      before do
        allow(Alert).to receive(:create)

        perform
      end

      it 'enqueues a create alert job' do
        expect(Alert).to have_received(:create).with(attributes)
      end
    end

    context 'when the type is create_recipient' do
      let(:type) { 'create_recipient' }
      let(:attributes) { { 'channel' => 'channel', 'address' => 'address' } }

      before do
        allow(Recipient).to receive(:create)

        perform
      end

      it 'enqueues a create recipient job' do
        expect(Recipient).to have_received(:create).with(attributes)
      end
    end

    context 'when the type is unsubscribe_recipient' do
      let(:type) { 'unsubscribe_recipient' }

      before do
        allow(Recipient).to receive(:find_by).and_return(recipient)
      end

      context 'and the recipient is NOT found' do
        let(:recipient) { nil }

        it 'does not raise an exception' do
          expect { perform }.not_to raise_error
        end
      end

      context 'and the recipient is found' do
        let(:recipient) { instance_double(Recipient) }

        before do
          allow(recipient).to receive(:destroy)

          perform
        end

        it 'deletes the recipient' do
          expect(recipient).to have_received(:destroy).with(no_args)
        end
      end
    end
  end
end
