class Recipient < ApplicationRecord
  validates :channel, presence: true
  validates :address, presence: true

  def notify(alert)
    SMSClient.new.send_message(from: '000-000-0000', to: address, message: alert.title)
  end
end
