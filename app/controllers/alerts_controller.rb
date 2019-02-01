class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  def index
    @alerts = Alert.order(id: :desc).page(params[:page])
    WASLogger.json(action: :find_alerts, status: :succeeded, params: { page: params[:page] })
  end

  def show
    WASLogger.json(action: :find_alert, status: :succeeded, params: { id: id })
  end

  def new
    @alert = Alert.new
  end

  def edit
  end

  def create
    @alert = Alert.new(alert_params)

    if @alert.save
      WASLogger.json(action: :create_alert, status: :succeeded, params: { alert: alert_params.to_h })
      redirect_to @alert, notice: 'Alert was successfully created.'
    else
      WASLogger.json(action: :create_alert, status: :failed, params: { alert: alert_params.to_h })
      render :new
    end
  end

  def update
    if @alert.update(alert_params)
      WASLogger.json(action: :update_alert, status: :succeeded, params: { alert: alert_params.to_h, id: id })
      redirect_to @alert, notice: 'Alert was successfully updated.'
    else
      WASLogger.json(action: :update_alert, status: :failed, params: { alert: alert_params.to_h, id: id })
      render :edit
    end
  end

  def destroy
    @alert.destroy
    WASLogger.json(action: :destroy_alert, status: :succeeded, params: { id: id })
    redirect_to alerts_url, notice: 'Alert was successfully destroyed.'
  end

  private

  def set_alert
    @alert = Alert.find(id)
  end

  def id
    params[:id]
  end

  def alert_params
    params.require(:alert).permit(:uuid, :title, :location, :message, :publish_at, :effective_at, :expires_at)
  end
end
