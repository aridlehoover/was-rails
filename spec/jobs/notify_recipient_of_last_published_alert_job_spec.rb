require 'rails_helper'

describe NotifyRecipientOfLastPublishedAlertJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(recipient) }

    let(:recipient) { instance_double(Recipient, notify: true) }
    let(:published_alerts) { [first_published_alert, last_published_alert] }
    let(:first_published_alert) { instance_double(Alert) }
    let(:last_published_alert) { instance_double(Alert) }

    before do
      allow(Alert).to receive(:published).and_return(published_alerts)

      perform
    end

    it 'calls notify on recipient with last published alert' do
      expect(recipient).to have_received(:notify).with(last_published_alert)
    end
  end
end
