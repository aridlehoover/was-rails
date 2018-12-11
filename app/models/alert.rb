class Alert < ApplicationRecord
  validates :uuid, presence: true
  validates :title, presence: true
  validates :location, presence: true
  validates :publish_at, presence: true
end
