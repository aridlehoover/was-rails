class ControllerAdapter
  attr_reader :controller

  PERFORMED_ACTIONS = {
    create: 'created',
    update: 'updated',
    destroy: 'deleted'
  }.freeze

  ACTION_TEMPLATE = {
    create: :new,
    update: :edit
  }.freeze

  def initialize(controller)
    @controller = controller
  end

  delegate :redirect_to, :render, to: :controller

  def succeeded(record)
    redirect_to record, notice: "#{record.class.name} was successfully #{PERFORMED_ACTIONS[action]}."
  end

  def failed(record)
    render ACTION_TEMPLATE[action], locals: { record: record }
  end

  def not_found
    render status: :not_found
  end

  private

  def action
    controller.params['action'].to_sym
  end
end
