class Source < ApplicationRecord
  validates :channel, presence: true
  validates :address, presence: true
end
