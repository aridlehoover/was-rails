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
    log_adapter = LogAdapter.new(:create_recipient, recipient_params)
    controller_adapter = ControllerAdapter.new(self)

    CreateRecipientCommand.new(recipient_params, [log_adapter, controller_adapter]).perform
  end

  def update
    @recipient = Recipient.find_by(id: id)

    if @recipient.present?
      if @recipient.update(recipient_params)
        ExternalLogger.log_and_increment(
          action: :update_recipient,
          actor: :administrator,
          status: :succeeded,
          params: params
        )
        redirect_to @recipient, notice: 'Recipient was successfully updated.'
      else
        ExternalLogger.log_and_increment(
          action: :update_recipient,
          actor: :administrator,
          status: :failed,
          params: params,
          errors: @recipient.errors.messages
        )
        render :edit
      end
    else
      ExternalLogger.log_and_increment(
        action: :update_recipient,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def destroy
    @recipient = Recipient.find_by(id: id)

    if @recipient.present?
      @recipient.destroy
      ExternalLogger.log_and_increment(
        action: :destroy_recipient,
        actor: :administrator,
        status: :succeeded,
        params: { id: id }
      )
      redirect_to recipients_url, notice: 'Recipient was successfully destroyed.'
    else
      ExternalLogger.log_and_increment(
        action: :destroy_recipient,
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

  def recipient_params
    params.require(:recipient).permit(:channel, :address)
  end
end
