require 'csv'

class ImportRecipientsJob < ApplicationJob
  queue_as :default

  def perform(import)
    return unless import.import_type.casecmp('recipients').zero?
    return unless import.file.content_type.casecmp('text/csv').zero?

    rows = CSV.parse(import.file.download)
    rows.each_with_index do |(channel, address), i|
      Recipient.create(channel: channel.downcase, address: address) unless i.zero?
    end
  end
end
