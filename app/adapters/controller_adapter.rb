class ControllerAdapter
  attr_reader :controller

  def initialize(controller)
    @controller = controller
  end

  delegate :redirect_to, :render, to: :controller

  def succeeded(record)
    redirect_to record, notice: "#{record.class.name} was successfully created."
  end

  def failed(record)
    render :new, locals: { record: record }
  end
end
