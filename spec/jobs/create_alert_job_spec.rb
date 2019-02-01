require 'rails_helper'

describe CreateAlertJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(alert_attributes) }

    let(:alert_attributes) do
      {
        'uuid' => uuid,
        'title' => title,
        'location' => location,
        'message' => message,
        'publish_at' => publish_at,
        'effective_at' => effective_at,
        'expires_at' => expires_at
      }
    end

    let(:uuid) { 'uuid' }
    let(:title) { 'title' }
    let(:location) { 'location' }
    let(:message) { 'message' }
    let(:publish_at) { 'publish_at' }
    let(:effective_at) { 'effective_at' }
    let(:expires_at) { 'expires_at' }
    let(:alert) { instance_double(Alert, persisted?: persisted?) }
    let(:persisted?) { true }

    before do
      allow(WASLogger).to receive(:json)
      allow(Alert).to receive(:create).and_return(alert)

      perform
    end

    it 'creates an alert with the provided alert attributes' do
      expect(Alert).to have_received(:create).with(alert_attributes)
    end

    context 'when the alert record is successfully created' do
      let(:persisted?) { true }

      it 'logs success' do
        expect(WASLogger).to have_received(:json).with(action: :create_alert, status: :succeeded, params: alert_attributes)
      end
    end

    context 'when the alert record is NOT created' do
      let(:persisted?) { false }

      it 'logs failure' do
        expect(WASLogger).to have_received(:json).with(action: :create_alert, status: :failed, params: alert_attributes)
      end
    end
  end
end
