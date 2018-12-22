require 'rails_helper'

describe ImportAlertsFromSourceJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(source) }

    let(:source) { instance_double(Source, channel: channel, address: 'address') }
    let(:channel) { 'channel' }
    let(:response) { instance_double('response', body: 'body') }
    let(:rss_feed) { instance_double('rss_feed', items: rss_feed_items) }
    let(:rss_feed_items) { [feed_item] }
    let(:feed_item) { nil }

    before do
      allow(RestClient).to receive(:get).and_return(response)
      allow(SimpleRSS).to receive(:parse).and_return(rss_feed)
      allow(Alert).to receive(:create)

      perform
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
  end
end
