class ExternalLogger
  def self.log_and_increment(params)
    json(params)
    increment(metric: params[:action], tags: { status: params[:status] })
  end

  def self.json(params)
    # Write structure logs to a file to be parsed and sent to a logging service asynchronously
  end

  def self.increment(metric:, tags: {})
    # tags_params = tags.reduce('') { |acc, (k, v)| "#{acc},#{k}=#{v}" }
    # Statsd.new(ENV['STATSD_HOST'], ENV['STATSD_PORT']).increment("#{metric}#{tags_params}")
  end
end
