class ControllerAdapter
  ACTION_PERFORMED = {
    create: 'created',
    destroy: 'destroyed'
  }.freeze

  attr_reader :controller

  def initialize(controller)
    @controller = controller
  end

  delegate :redirect_to, :render, to: :controller

  def succeeded(record)
    redirect_to record, notice: "#{record.class.name} was successfully #{ACTION_PERFORMED[action]}."
  end

  def failed(record)
    render :new, locals: { record: record }
  end

  def not_found
    render status: :not_found
  end

  private

  def action
    controller.params[:action].to_sym
  end
end
