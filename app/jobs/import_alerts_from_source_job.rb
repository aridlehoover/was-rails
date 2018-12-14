class ImportAlertsFromSourceJob < ApplicationJob
  def perform(source)
    response = RestClient.get(source.address)
    feed = SimpleRSS.parse(response.body)

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
  end
end
