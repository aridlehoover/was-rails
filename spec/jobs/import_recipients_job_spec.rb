require 'rails_helper'

describe ImportRecipientsJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(import) }

    let(:import) { instance_double(Import) }

    before do
      allow(import).to receive(:import_recipients)

      perform
    end

    it 'imports recipients' do
      expect(import).to have_received(:import_recipients)
    end
  end
end
