require 'rails_helper'

describe Source, type: :model do
  subject(:source) { described_class.new(channel: channel, address: address) }

  let(:channel) { 'channel' }
  let(:address) { 'address' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:channel) }
    it { is_expected.to validate_presence_of(:address) }
  end

  describe '#import_alerts' do
    subject(:import_alerts) { source.import_alerts }

    before do
      allow(ImportAlertsFromSourceJob).to receive(:perform_later)

      source.save
    end

    it 'enqueues a job to import alerts' do
      expect(ImportAlertsFromSourceJob).to have_received(:perform_later).with(source)
    end
  end
end
