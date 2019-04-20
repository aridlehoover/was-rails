class TelemetryActor < Actor
  corresponds_to :create_alert

  def to_sym
    :telemetry
  end
end
