class TelemetryActor < Actor
  corresponds_to port: :sqs, command: :create_alert

  def to_sym
    :telemetry
  end
end
