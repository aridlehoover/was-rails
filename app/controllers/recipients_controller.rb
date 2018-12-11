class RecipientsController < ApplicationController
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]

  def index
    @recipients = Recipient.all
  end

  def show
  end

  def new
    @recipient = Recipient.new
  end

  def edit
  end

  def create
    @recipient = Recipient.new(recipient_params)

    if @recipient.save
      redirect_to @recipient, notice: 'Recipient was successfully created.'
    else
      render :new
    end
  end

  def update
    if @recipient.update(recipient_params)
      redirect_to @recipient, notice: 'Recipient was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @recipient.destroy
    redirect_to recipients_url, notice: 'Recipient was successfully destroyed.'
  end

  private

  def set_recipient
    @recipient = Recipient.find(params[:id])
  end

  def recipient_params
    params.require(:recipient).permit(:channel, :address)
  end
end
