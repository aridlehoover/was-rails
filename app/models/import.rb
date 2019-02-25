class Import < ApplicationRecord
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
      create_recipient(channel, address) unless i.zero?
    end
    failed_recipients = recipients.compact.reject(&:persisted?)

    if failed_recipients.none?
      ExternalLogger.log_and_increment(
        action: :import_recipients,
        actor: :administrator,
        status: :succeeded,
        params: attributes
      )
    else
      ExternalLogger.log_and_increment(
        action: :import_recipients,
        actor: :administrator,
        status: :failed,
        params: attributes,
        failed_recipients: failed_recipients.map(&:attributes)
      )
    end
  end

  private

  def create_recipient(channel, address)
    recipient = Recipient.create(channel: channel.downcase, address: address)

    if recipient.persisted?
      ExternalLogger.log_and_increment(
        action: :create_recipient,
        actor: :administrator,
        status: :succeeded,
        params: recipient.attributes
      )
    else
      ExternalLogger.log_and_increment(
        action: :create_recipient,
        actor: :administrator,
        status: :failed,
        params: recipient.attributes,
        errors: recipient.errors.messages
      )
    end

    recipient
  end
end
