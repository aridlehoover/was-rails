require 'csv'

class ImportRecipientsJob < ApplicationJob
  queue_as :default

  def perform(import)
    import.import_recipients
  end
end
