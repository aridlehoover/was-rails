class TelecomActor < Actor
  corresponds_to :create_recipient
  corresponds_to :unsubscribe_recipient

  def to_sym
    :telecom
  end
end
