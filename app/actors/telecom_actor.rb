class TelecomActor < Actor
  corresponds_to port: :sqs, command: :create_recipient
  corresponds_to port: :sqs, command: :unsubscribe_recipient

  def to_sym
    :telecom
  end
end
