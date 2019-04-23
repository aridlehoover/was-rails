class UpdateRecipientCommand < Command
  corresponds_to :update_recipient

  def perform
    return adapters.each(&:not_found) if recipient.blank?

    if recipient.update(params[:attributes])
      adapters.each { |adapter| adapter.succeeded(recipient) }
    else
      adapters.each { |adapter| adapter.failed(recipient) }
    end

    recipient
  end

  private

  def recipient
    @recipient ||= Recipient.find_by(id: params[:id])
  end
end
