class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  def index
    @alerts = Alert.order(id: :desc).page(params[:page])
  end

  def show
  end

  def new
    @alert = Alert.new
  end

  def edit
  end

  def create
    @alert = Alert.create(alert_params)

    if @alert.persisted?
      redirect_to @alert, notice: 'Alert was successfully created.'
    else
      render :new
    end
  end

  def update
    if @alert.update(alert_params)
      redirect_to @alert, notice: 'Alert was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @alert.destroy
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
