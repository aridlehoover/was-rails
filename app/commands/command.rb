class Command
  extend Industrialist::Manufacturable

  attr_reader :params, :adapters

  def initialize(params, adapters)
    @params = params
    @adapters = Array.wrap(adapters).compact
  end
end
