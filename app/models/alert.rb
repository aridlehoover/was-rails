class Alert < ApplicationRecord
  ALLOWED_ATTRIBUTES = ['uuid', 'title', 'location', 'message', 'publish_at', 'effective_at', 'expires_at'].freeze

  validates :uuid, presence: true
  validates :title, presence: true
  validates :location, presence: true
  validates :publish_at, presence: true

  scope :published, -> { where('publish_at < :now AND expires_at > :now', now: Time.current) }

  after_create :enqueue_notify_all_recipients_job

  def enqueue_notify_all_recipients_job
    NotifyAllRecipientsJob.set(wait_until: publish_at).perform_later(self) unless expired?
  end

  private

  def expired?
    expires_at.present? && expires_at < Time.current
  end
end
