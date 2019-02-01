require 'rails_helper'

describe ImportAlertsFromSourceJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(source) }

    let(:source) { instance_double(Source) }

    before do
      allow(source).to receive(:import_alerts)

      perform
    end

    it 'imports alerts from the source' do
      expect(source).to have_received(:import_alerts)
    end
  end
end
