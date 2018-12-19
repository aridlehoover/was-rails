class Alert < ApplicationRecord
  validates :uuid, presence: true
  validates :title, presence: true
  validates :location, presence: true
  validates :publish_at, presence: true

  scope :published, -> { where('publish_at < :now AND expires_at > :now', now: Time.current) }

  after_create :notify_all_recipients

  def notify_all_recipients
    NotifyAllRecipientsJob.set(wait_until: publish_at).perform_later(self) unless expired?
  end

  private

  def expired?
    expires_at.present? && expires_at < Time.current
  end
end
