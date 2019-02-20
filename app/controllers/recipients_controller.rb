class RecipientsController < ApplicationController
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]

  def index
    @recipients = Recipient.page(params[:page])
  end

  def show
  end

  def new
    @recipient = Recipient.new
  end

  def edit
  end

  def create
    @recipient = Recipient.create(recipient_params)

    if @recipient.persisted?
      WASLogger.json(action: :create_recipient, actor: :administrator, status: :succeeded, params: recipient_params.to_h)
      redirect_to @recipient, notice: 'Recipient was successfully created.'
    else
      WASLogger.json(
        action: :create_recipient,
        actor: :administrator,
        status: :failed,
        params: recipient_params.to_h,
        errors: @recipient.errors.messages
      )
      render :new
    end
  end

  def update
    if @recipient.update(recipient_params)
      WASLogger.json(action: :update_recipient, actor: :administrator, status: :succeeded, params: recipient_params.to_h)
      redirect_to @recipient, notice: 'Recipient was successfully updated.'
    else
      WASLogger.json(
        action: :update_recipient,
        actor: :administrator,
        status: :failed,
        params: recipient_params.to_h,
        errors: @recipient.errors.messages
      )
      render :edit
    end
  end

  def destroy
    @recipient.destroy
    WASLogger.json(action: :destroy_recipient, actor: :administrator, status: :succeeded, params: { id: id })
    redirect_to recipients_url, notice: 'Recipient was successfully destroyed.'
  end

  private

  def set_recipient
    @recipient = Recipient.find(id)
  end

  def id
    params[:id]
  end

  def recipient_params
    params.require(:recipient).permit(:channel, :address)
  end
end
