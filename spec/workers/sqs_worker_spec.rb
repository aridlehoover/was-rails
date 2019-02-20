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
      let(:alert) { instance_double(Alert, persisted?: persisted?) }
      let(:persisted?) { true }

      before do
        allow(Alert).to receive(:create).and_return(alert)
        allow(WASLogger).to receive(:json)
      end

      it 'creates an alert' do
        perform

        expect(Alert).to have_received(:create).with(attributes)
      end

      context 'when the alert is NOT persisted' do
        let(:persisted?) { false }
        let(:alert_errors) { instance_double('alert_errors') }
        let(:alert_error_messages) { instance_double('alert_error_messages') }

        before do
          allow(alert).to receive(:errors).and_return(alert_errors)
          allow(alert_errors).to receive(:messages).and_return(alert_error_messages)

          perform
        end

        it 'logs failure' do
          expect(WASLogger).to have_received(:json).with(
            action: :create_alert,
            actor: :telemetry,
            status: :failed,
            params: body,
            errors: alert_error_messages
          )
        end
      end

      context 'when the alert is persisted' do
        let(:persisted?) { true }

        before { perform }

        it 'logs success' do
          expect(WASLogger).to have_received(:json).with(
            action: :create_alert,
            actor: :telemetry,
            status: :succeeded,
            params: body
          )
        end
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
