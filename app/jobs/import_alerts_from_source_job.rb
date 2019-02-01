class ImportAlertsFromSourceJob < ApplicationJob
  queue_as :default

  def perform(source)
    source.import_alerts
  end
end
