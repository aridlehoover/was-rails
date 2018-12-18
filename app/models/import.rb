class Import < ApplicationRecord
  VALID_IMPORT_TYPES = ['recipients'].freeze

  validates :import_type, inclusion: { in: VALID_IMPORT_TYPES }

  has_one_attached :file

  after_create :import_recipients

  def import_recipients
    ImportRecipientsJob.perform_later(self)
  end
end
