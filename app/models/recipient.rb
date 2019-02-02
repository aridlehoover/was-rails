class Recipient < ApplicationRecord
  SENDGRID_ENDPOINT = 'https://api.sendgrid.com/v3/mail/send'.freeze
  SLACK_CHANNEL = '#weather-alerts'.freeze
  SLACK_USERNAME = 'was-bot'.freeze
  SMS_FROM = '+14156897774'.freeze

  validates :channel, presence: true
  validates :address, presence: true

  after_create :notify_last_published_alert

  def notify_last_published_alert
    NotifyRecipientOfLastPublishedAlertJob.perform_later(self)
  end

  def notify(alert)
    case channel.to_sym
    when :sms
      send_via_sms(address, alert.title)
    when :email
      send_via_email(address, alert.title)
    when :twitter
      send_via_twitter(address, alert.title)
    when :messenger
      send_via_messenger(address, alert.title)
    when :whatsapp
      send_via_whatsapp(address, alert.title)
    when :slack
      send_via_slack(address, alert.title)
    end

    WASLogger.json(action: :recipient_notified, status: :succeeded, params: { channel: channel, address: address, alert: alert.attributes })
  end

  private

  def send_via_sms(address, message)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    client.api.account.messages.create(from: SMS_FROM, to: address, body: message)
  end

  def send_via_email(address, message)
    RestClient.post(
      SENDGRID_ENDPOINT,
      {
        to: [{ email: address }],
        subject: 'Alert',
        content: [{ value: message, type: 'text/plain' }]
      },
      'Authorization' => "Bearer #{ENV['SENDGRID_API_KEY']}"
    )
  end

  def send_via_twitter(address, message)
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end

    twitter_client.update("#{address} - #{message}")
  end

  def send_via_messenger(address, message)
    Facebook::Messenger::Bot.deliver(
      {
        recipient: { id: address },
        message: { text: message },
        message_type: Facebook::Messenger::Bot::MessagingType::UPDATE
      },
      access_token: ENV['FACEBOOK_ACCESS_TOKEN']
    )
  end

  def send_via_whatsapp(address, message)
    whats = Whats::Api.new
    whats.send_message(address, message)
  end

  def send_via_slack(address, message)
    slack_notifier = Slack::Notifier.new(address, channel: SLACK_CHANNEL, username: SLACK_USERNAME)
    slack_notifier.ping(message)
  end
end
