require 'rails_helper'

describe NotifyAllRecipientsJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(alert) }

    let(:recipients) { [instance_double(Recipient, notify: true), instance_double(Recipient, notify: true)] }
    let(:alert) { instance_double(Alert) }

    before do
      allow(Recipient).to receive(:all).and_return(recipients)

      perform
    end

    it 'calls notify on all recipients' do
      expect(recipients).to all(have_received(:notify).with(alert))
    end
  end
end
