class ControllerAdapter
  attr_reader :controller

  def initialize(controller)
    @controller = controller
  end

  delegate :redirect_to, :render, to: :controller

  def operation_succeeded(record)
    redirect_to record, notice: "#{record.class.name} was successfully created."
  end

  def operation_failed(record)
    render :new, locals: { record: record }
  end
end
