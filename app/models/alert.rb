class Alert < ApplicationRecord
  validates :uuid, presence: true
  validates :title, presence: true
  validates :location, presence: true
  validates :publish_at, presence: true

  after_create :notify_all_recipients

  def notify_all_recipients
    NotifyAllRecipientsJob.perform_later(self)
  end
end
