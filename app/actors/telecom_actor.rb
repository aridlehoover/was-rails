class TelecomActor < Actor
  corresponds_to sqs: :create_recipient
  corresponds_to sqs: :unsubscribe_recipient
end
