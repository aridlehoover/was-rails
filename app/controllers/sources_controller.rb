class SourcesController < ApplicationController
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  def index
    @sources = Source.page(params[:page])

    if @sources.any?
      ExternalLogger.log_and_increment(
        action: :find_sources,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.log_and_increment(
        action: :find_sources,
        actor: :administrator,
        status: :not_found,
        params: params
      )
    end
  end

  def show
    @source = Source.find_by(id: id)

    if @source.present?
      ExternalLogger.log_and_increment(
        action: :find_source,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLogger.log_and_increment(
        action: :find_source,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def new
    @source = Source.new

    ExternalLogger.log_and_increment(
      action: :new_source,
      actor: :administrator,
      status: :succeeded
    )
  end

  def edit
    @source = Source.find_by(id: id)

    if @source.present?
      ExternalLogger.log_and_increment(
        action: :edit_source,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    else
      ExternalLoggerds.json(
        action: :edit_source,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def create
    @source = Source.create(source_params)

    if @source.persisted?
      ExternalLogger.log_and_increment(action: :create_source, actor: :administrator, status: :succeeded, params: source_params.to_h)
      redirect_to @source, notice: 'Source was successfully created.'
    else
      ExternalLogger.log_and_increment(
        action: :create_source,
        actor: :administrator,
        status: :failed,
        params: source_params.to_h,
        errors: @source.errors.messages
      )
      render :new
    end
  end

  def update
    @source = Source.find_by(id: id)

    if @source.present?
      if @source.update(source_params)
        ExternalLogger.log_and_increment(
          action: :update_source,
          actor: :administrator,
          status: :succeeded,
          params: params
        )
        redirect_to @source, notice: 'Alert was successfully updated.'
      else
        ExternalLogger.log_and_increment(
          action: :update_source,
          actor: :administrator,
          status: :failed,
          params: params,
          errors: @source.errors.messages
        )
        render :edit
      end
    else
      ExternalLogger.log_and_increment(
        action: :update_source,
        actor: :administrator,
        status: :not_found,
        params: params
      )
      render status: :not_found
    end
  end

  def destroy
    @source.destroy
    ExternalLogger.log_and_increment(
      action: :destroy_source,
      actor: :administrator,
      status: :succeeded,
      params: { id: id }
    )
    redirect_to sources_url, notice: 'Source was successfully destroyed.'
  end

  private

  def id
    params[:id]
  end

  def source_params
    params.require(:source).permit(:channel, :address)
  end
end
