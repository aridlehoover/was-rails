class TelemetryActor < Actor
  corresponds_to sqs: :create_alert
end
