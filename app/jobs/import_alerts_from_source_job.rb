class ImportAlertsFromSourceJob < ApplicationJob
  queue_as :default

  def perform(source)
    response = RestClient.get(source.address)
    feed = SimpleRSS.parse(response.body)

    case source.channel
    when 'NWS Warnings ATOM feed'
      feed.items.each do |item|
        Alert.create(
          uuid: item.id,
          title: item.title,
          location: item.cap_areaDesc,
          message: item.summary,
          publish_at: item.published,
          effective_at: item.cap_effective,
          expires_at: item.cap_expires
        )
      end
    when 'PTWC - Pacific Ocean Bulletins RSS feed'
      feed.items.each do |item|
        Alert.create(
          uuid: item.guid,
          title: item.title,
          location: item.description.match(/LOCATION\s+(.*)\n/)[1],
          message: item.description,
          publish_at: item.pubDate
        )
      end
    when 'USGS Earthquakes ATOM feed'
      feed.items.each do |item|
        Alert.create(
          uuid: item.id,
          title: item.title,
          location: item.title.match(/\s-\s(.*)$/)[1],
          message: item.summary,
          publish_at: item.updated
        )
      end
    end
  end
end
