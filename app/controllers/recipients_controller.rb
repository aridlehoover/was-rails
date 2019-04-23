class RecipientsController < ApplicationController
  def index
    @recipients = Recipient.page(params[:page])

    if @recipients.any?
      ExternalLogger.log_and_increment(
        action: :find_recipients,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.log_and_increment(
        action: :find_recipients,
        actor: :administrator,
        status: :not_found,
        params: params
      )
    end
  end

  def show
    @recipient = Recipient.find_by(id: id)

    if @recipient.present?
      ExternalLogger.log_and_increment(
        action: :find_recipient,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.log_and_increment(
        action: :find_recipient,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def new
    @recipient = Recipient.new

    ExternalLogger.log_and_increment(
      action: :new_recipient,
      actor: :administrator,
      status: :succeeded
    )
  end

  def edit
    @recipient = Recipient.find_by(id: id)

    if @recipient.present?
      ExternalLogger.log_and_increment(
        action: :edit_recipient,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLoggerds.json(
        action: :edit_recipient,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def create
    CommandBuilder.new(:create_recipient, recipient_params)
      .controller(self)
      .build
      .perform
  end

  def update
    CommandBuilder.new(:update_recipient, id: id, attributes: recipient_params)
      .controller(self)
      .build
      .perform
  end

  def destroy
    CommandBuilder.new(:unsubscribe_recipient, id: id)
      .controller(self)
      .build
      .perform
  end

  private

  def id
    params[:id]
  end

  def recipient_params
    params.require(:recipient).permit(:channel, :address)
  end
end
