class AlertsController < ApplicationController
  def index
    @alerts = Alert.order(id: :desc).page(params[:page])

    if @alerts.any?
      ExternalLogger.log_and_increment(
        action: :find_alerts,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.log_and_increment(
        action: :find_alerts,
        actor: :administrator,
        status: :not_found,
        params: params
      )
    end
  end

  def show
    @alert = Alert.find_by(id: id)

    if @alert.present?
      ExternalLogger.log_and_increment(
        action: :find_alert,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.log_and_increment(
        action: :find_alert,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def new
    @alert = Alert.new

    ExternalLogger.log_and_increment(
      action: :new_alert,
      actor: :administrator,
      status: :succeeded
    )
  end

  def edit
    @alert = Alert.find_by(id: id)

    if @alert.present?
      ExternalLogger.log_and_increment(
        action: :edit_alert,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLoggerds.json(
        action: :edit_alert,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def create
    log_adapter = LogAdapter.new(alert_params)
    controller_adapter = ControllerAdapter.new(self)

    CreateAlertOperation.new(alert_params, [log_adapter, controller_adapter]).perform
  end

  def update
    @alert = Alert.find_by(id: id)

    if @alert.present?
      if @alert.update(alert_params)
        ExternalLogger.log_and_increment(
          action: :update_alert,
          actor: :administrator,
          status: :succeeded,
          params: params
        )
        redirect_to @alert, notice: 'Alert was successfully updated.'
      else
        ExternalLogger.log_and_increment(
          action: :update_alert,
          actor: :administrator,
          status: :failed,
          params: params,
          errors: @alert.errors.messages
        )
        render :edit
      end
    else
      ExternalLogger.log_and_increment(
        action: :update_alert,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def destroy
    @alert = Alert.find_by(id: id)

    if @alert.present?
      @alert.destroy
      ExternalLogger.log_and_increment(
        action: :destroy_alert,
        actor: :administrator,
        status: :succeeded,
        params: { id: id }
      )
      redirect_to alerts_url, notice: 'Alert was successfully destroyed.'
    else
      ExternalLogger.log_and_increment(
        action: :destroy_alert,
        actor: :administrator,
        status: :not_found,
        params: { id: id }
      )
      render status: :not_found
    end
  end

  private

  def id
    params[:id]
  end

  def alert_params
    params.require(:alert).permit(:uuid, :title, :location, :message, :publish_at, :effective_at, :expires_at)
  end
end
