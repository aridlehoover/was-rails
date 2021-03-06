require 'rails_helper'

describe Source, type: :model do
  subject(:source) { described_class.new(source_attributes) }

  let(:source_attributes) { { channel: channel, address: address } }
  let(:channel) { 'channel' }
  let(:address) { 'address' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:channel) }
    it { is_expected.to validate_presence_of(:address) }
  end

  describe '#enqueue_import_alerts_job' do
    subject(:enqueue_import_alerts_job) { source.enqueue_import_alerts_job }

    before do
      allow(ImportAlertsFromSourceJob).to receive(:perform_later)

      enqueue_import_alerts_job
    end

    it 'enqueues a job to import alerts' do
      expect(ImportAlertsFromSourceJob).to have_received(:perform_later).with(source)
    end
  end

  describe '#import_alerts' do
    subject(:import_alerts) { source.import_alerts }

    let(:response) { instance_double('response', body: 'body') }
    let(:rss_feed) { instance_double('rss_feed', items: rss_feed_items) }
    let(:rss_feed_items) { [feed_item] }
    let(:feed_item) { nil }
    let(:alert) { instance_double(Alert, persisted?: persisted?, attributes: alert_attributes, errors: errors) }
    let(:errors) { instance_double('errors', messages: error_messages) }
    let(:error_messages) { instance_double('error_messages') }
    let(:alert_attributes) { {} }
    let(:persisted?) { true }

    before do
      allow(RestClient).to receive(:get).and_return(response)
      allow(SimpleRSS).to receive(:parse).and_return(rss_feed)
      allow(Alert).to receive(:create).and_return(alert)
      allow(ExternalLogger).to receive(:json)

      import_alerts
    end

    it 'fetches items from the source' do
      expect(RestClient).to have_received(:get).with(source.address)
      expect(SimpleRSS).to have_received(:parse).with(response.body)
    end

    context 'when the channel is the NWS Warnings ATOM feed' do
      let(:channel) { 'NWS Warnings ATOM feed' }
      let(:feed_item) do
        instance_double(
          'feed_item',
          id: 'uuid',
          title: 'título',
          cap_areaDesc: 'ubicación',
          summary: 'resumen',
          published: 'publicación',
          cap_effective: 'efectivo',
          cap_expires: 'expiración'
        )
      end

      it 'creates an alert from each fetched item' do
        expect(Alert).to have_received(:create).with(
          uuid: 'uuid',
          title: 'título',
          location: 'ubicación',
          message: 'resumen',
          publish_at: 'publicación',
          effective_at: 'efectivo',
          expires_at: 'expiración'
        )
      end
    end

    context 'when the channel is the PTWC - Pacific Ocean Bulletins RSS feed' do
      let(:channel) { 'PTWC - Pacific Ocean Bulletins RSS feed' }
      let(:feed_item) do
        instance_double(
          'feed_item',
          guid: 'uuid',
          title: 'título',
          description: "TSUNAMI!\n  * LOCATION       SOUTHERN ALASKA\n",
          pubDate: 'publicación'
        )
      end

      it 'creates an alert from each fetched item' do
        expect(Alert).to have_received(:create).with(
          uuid: 'uuid',
          title: 'título',
          location: 'SOUTHERN ALASKA',
          message: "TSUNAMI!\n  * LOCATION       SOUTHERN ALASKA\n",
          publish_at: 'publicación'
        )
      end
    end

    context 'when the channel is the USGS Earthquakes ATOM feed' do
      let(:channel) { 'USGS Earthquakes ATOM feed' }
      let(:feed_item) do
        instance_double(
          'feed_item',
          id: 'uuid',
          title: 'título - ubicación',
          summary: 'resumen',
          updated: 'publicación'
        )
      end

      it 'creates an alert from each fetched item' do
        expect(Alert).to have_received(:create).with(
          uuid: 'uuid',
          title: 'título - ubicación',
          location: 'ubicación',
          message: 'resumen',
          publish_at: 'publicación'
        )
      end
    end

    context 'when there are NO failures importing alerts' do
      let(:channel) { 'USGS Earthquakes ATOM feed' }
      let(:feed_item) do
        instance_double(
          'feed_item',
          id: 'uuid',
          title: 'título - ubicación',
          summary: 'resumen',
          updated: 'publicación'
        )
      end
      let(:persisted?) { true }
      let(:alert_attributes) do
        {
          uuid: 'uuid',
          title: 'título - ubicación',
          location: 'ubicación',
          message: 'resumen',
          publish_at: 'publicación'
        }
      end

      it 'logs success for the import' do
        expect(ExternalLogger)
          .to have_received(:json)
          .with(action: :import_alerts, actor: :administrator, status: :succeeded, params: source.attributes)
      end

      it 'logs success for each created alert' do
        expect(ExternalLogger)
          .to have_received(:json)
          .with(action: :create_alert, actor: :administrator, status: :succeeded, params: alert_attributes)
      end
    end

    context 'when there are SOME failures importing alerts' do
      let(:channel) { 'USGS Earthquakes ATOM feed' }
      let(:feed_item) do
        instance_double(
          'feed_item',
          id: nil,
          title: 'título - ubicación',
          summary: 'resumen',
          updated: 'publicación'
        )
      end
      let(:alert_attributes) do
        {
          uuid: nil,
          title: 'título - ubicación',
          location: 'ubicación',
          message: 'resumen',
          publish_at: 'publicación'
        }
      end
      let(:persisted?) { false }

      it 'logs failure for the import' do
        expect(ExternalLogger).to have_received(:json).with(
          action: :import_alerts,
          actor: :administrator,
          status: :failed,
          params: source.attributes
        )
      end

      it 'logs failure for each failed alert' do
        expect(ExternalLogger)
          .to have_received(:json)
          .with(
            action: :create_alert,
            actor: :administrator,
            status: :failed,
            params: alert_attributes,
            errors: error_messages
          )
      end
    end
  end
end
