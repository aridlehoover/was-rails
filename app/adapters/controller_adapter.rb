class ControllerAdapter
  attr_reader :controller

  def initialize(controller)
    @controller = controller
  end

  delegate :redirect_to, :render, to: :controller

  def operation_succeeded(alert)
    redirect_to alert, notice: 'Alert was successfully created.'
  end

  def operation_failed(alert)
    render :new, locals: { alert: alert }
  end
end
