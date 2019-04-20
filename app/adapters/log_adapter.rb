class LogAdapter
  attr_reader :action, :params, :options

  def initialize(action, params, options = {})
    @action = action
    @params = params.to_h
    @options = options
  end

  def succeeded(_record)
    ExternalLogger.log_and_increment(
      {
        action: action,
        actor: :administrator,
        status: :succeeded,
        params: params
      }.merge(options)
    )
  end

  def failed(record)
    ExternalLogger.log_and_increment(
      {
        action: action,
        actor: :administrator,
        status: :failed,
        params: params,
        errors: record.errors.messages
      }.merge(options)
    )
  end

  def not_found
    ExternalLogger.log_and_increment(
      {
        action: action,
        actor: :administrator,
        status: :not_found,
        params: params
      }.merge(options)
    )
  end
end
