class LogAdapter
  attr_reader :action, :params, :options

  def initialize(action, params, options = {})
    @action = action
    @params = params
    @options = options
  end

  def operation_succeeded(_record)
    ExternalLogger.log_and_increment(
      {
        action: action,
        actor: :administrator,
        status: :succeeded,
        params: params
      }.merge(options)
    )
  end

  def operation_failed(record)
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
end
