require 'rails_helper'

describe Alert, type: :model do
  subject(:alert) { described_class.new(uuid: 'uuid', title: 'title', location: 'location', publish_at: '2019-01-01 00:00:00') }

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
end
