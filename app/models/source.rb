class Source < ApplicationRecord
  include Loggable

  validates :channel, presence: true
  validates :address, presence: true

  after_commit :enqueue_import_alerts_job

  def enqueue_import_alerts_job
    ImportAlertsFromSourceJob.perform_later(self)
  end

  def import_alerts
    alerts = parsed_feed_data.items.map { |item| Alert.create(alert_attributes(item)) }
    failed_alerts = alerts.reject(&:persisted?)

    if failed_alerts.none?
      WASLogger.json(action: :import_alerts, actor: :administrator, status: :succeeded, params: { source: attributes })
    else
      WASLogger.json(
        action: :import_alerts,
        actor: :administrator,
        status: :failed,
        params: { source: attributes, failed_alerts: failed_alerts.map(&:attributes) }
      )
    end
  end

  private

  def raw_feed_data
    RestClient.get(address)
  end

  def parsed_feed_data
    SimpleRSS.parse(raw_feed_data.body)
  end

  def alert_attributes(item)
    case channel
    when 'NWS Warnings ATOM feed'
      nws_warnings_attributes(item)
    when 'PTWC - Pacific Ocean Bulletins RSS feed'
      ptwc_pacific_ocean_bulletins_attributes(item)
    when 'USGS Earthquakes ATOM feed'
      usgs_earthquakes_attributes(item)
    end
  end

  def nws_warnings_attributes(item)
    {
      uuid: item.id,
      title: item.title,
      location: item.cap_areaDesc,
      message: item.summary,
      publish_at: item.published,
      effective_at: item.cap_effective,
      expires_at: item.cap_expires
    }
  end

  def ptwc_pacific_ocean_bulletins_attributes(item)
    {
      uuid: item.guid,
      title: item.title,
      location: item.description.match(/LOCATION\s+(.*)\n/)[1],
      message: item.description,
      publish_at: item.pubDate
    }
  end

  def usgs_earthquakes_attributes(item)
    {
      uuid: item.id,
      title: item.title,
      location: item.title.match(/\s-\s(.*)$/)[1],
      message: item.summary,
      publish_at: item.updated
    }
  end
end
