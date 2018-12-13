require 'rails_helper'

describe Alert, type: :model do
  subject(:alert) { described_class.new(alert_attributes) }

  let(:alert_attributes) { { uuid: 'uuid', title: 'title', location: 'location', publish_at: publish_at, expires_at: expires_at } }
  let(:publish_at) { '2019-01-01 00:00:00' }
  let(:expires_at) { '2019-01-01 01:00:00' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:publish_at) }
  end

  describe 'after_create' do
    let(:recipients) { [instance_double(Recipient)] }

    before do
      allow(NotifyAllRecipientsJob).to receive(:perform_later)

      alert.save
    end

    it 'enqueues a job to notify all recipients' do
      expect(NotifyAllRecipientsJob).to have_received(:perform_later).with(alert)
    end
  end

  describe '.published' do
    subject(:published) { described_class.published }

    context 'when the alert is NOT published' do
      let(:publish_at) { Time.current + 1.hour }

      before { alert.save! }

      it 'does NOT return the alert' do
        expect(published).not_to include(alert)
      end
    end

    context 'when the alert is published' do
      let(:publish_at) { Time.current - 2.hours }

      context 'and the alert is expired' do
        let(:expires_at) { Time.current - 1.hour }

        before { alert.save! }

        it 'does NOT return the alert' do
          expect(published).not_to include(alert)
        end
      end

      context 'and the alert is NOT expired' do
        let(:expires_at) { Time.current + 1.hour }

        before { alert.save! }

        it 'returns the alert' do
          expect(published).to include(alert)
        end
      end
    end
  end
end
