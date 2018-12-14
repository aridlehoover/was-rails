class Source < ApplicationRecord
  validates :channel, presence: true
  validates :address, presence: true

  after_create :import_alerts

  def import_alerts
    ImportAlertsFromSourceJob.perform_later(self)
  end
end
