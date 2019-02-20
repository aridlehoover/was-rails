class Import < ApplicationRecord
  include Loggable

  VALID_IMPORT_TYPES = ['recipients'].freeze

  validates :import_type, inclusion: { in: VALID_IMPORT_TYPES }

  has_one_attached :file

  after_create :enqueue_import_recipients_job

  def enqueue_import_recipients_job
    ImportRecipientsJob.perform_later(self)
  end

  def import_recipients
    return unless import_type.casecmp('recipients').zero?
    return unless file.content_type.casecmp('text/csv').zero?

    rows = CSV.parse(file.download)
    recipients = rows.map.with_index do |(channel, address), i|
      Recipient.create(channel: channel.downcase, address: address) unless i.zero?
    end

    if recipients.compact.reject(&:persisted?).none?
      WASLogger.json(action: :import_recipients, status: :succeeded, params: attributes)
    else
      WASLogger.json(action: :import_recipients, status: :failed, params: attributes)
    end
  end
end
