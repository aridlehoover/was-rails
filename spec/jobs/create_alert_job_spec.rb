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

    before do
      allow(Alert).to receive(:create)

      perform
    end

    it 'creates an alert with the provided alert attributes' do
      expect(Alert).to have_received(:create).with(alert_attributes)
    end
  end
end
