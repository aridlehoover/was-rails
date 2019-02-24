class AlertsController < ApplicationController
  def index
    @alerts = Alert.order(id: :desc).page(params[:page])

    if @alerts.any?
      ExternalLogger.json(
        action: :find_alerts,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.json(
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
      ExternalLogger.json(
        action: :find_alert,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.json(
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

    ExternalLogger.json(
      action: :new_alert,
      actor: :administrator,
      status: :succeeded
    )
  end

  def edit
    @alert = Alert.find_by(id: id)

    if @alert.present?
      ExternalLogger.json(
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
    @alert = Alert.create(alert_params)
    if @alert.persisted?
      ExternalLogger.json(
        action: :create_alert,
        actor: :administrator,
        status: :succeeded,
        params: alert_params.to_h
      )
      redirect_to @alert, notice: 'Alert was successfully created.'
    else
      ExternalLogger.json(
        action: :create_alert,
        actor: :administrator,
        status: :failed,
        params: alert_params.to_h,
        errors: @alert.errors.messages
      )
      render :new
    end
  end

  def update
    @alert = Alert.find_by(id: id)

    if @alert.present?
      if @alert.update(alert_params)
        ExternalLogger.json(
          action: :update_alert,
          actor: :administrator,
          status: :succeeded,
          params: params
        )
        redirect_to @alert, notice: 'Alert was successfully updated.'
      else
        ExternalLogger.json(
          action: :update_alert,
          actor: :administrator,
          status: :failed,
          params: params,
          errors: @alert.errors.messages
        )
        render :edit
      end
    else
      ExternalLogger.json(
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
      ExternalLogger.json(
        action: :destroy_alert,
        actor: :administrator,
        status: :succeeded,
        params: { id: id }
      )
      redirect_to alerts_url, notice: 'Alert was successfully destroyed.'
    else
      ExternalLogger.json(
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
