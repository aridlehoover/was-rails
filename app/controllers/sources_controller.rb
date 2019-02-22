class SourcesController < ApplicationController
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  def index
    @sources = Source.page(params[:page])
  end

  def show
  end

  def new
    @source = Source.new
  end

  def edit
  end

  def create
    @source = Source.create(source_params)

    if @source.persisted?
      ExternalLogger.json(action: :create_source, actor: :administrator, status: :succeeded, params: source_params.to_h)
      redirect_to @source, notice: 'Source was successfully created.'
    else
      ExternalLogger.json(
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
    if @source.update(source_params)
      ExternalLogger.json(action: :update_source, actor: :administrator, status: :succeeded, params: source_params.to_h)
      redirect_to @source, notice: 'Source was successfully updated.'
    else
      ExternalLogger.json(
        action: :update_source,
        actor: :administrator,
        status: :failed,
        params: source_params.to_h,
        errors: @source.errors.messages
      )
      render :edit
    end
  end

  def destroy
    @source.destroy
    ExternalLogger.json(action: :destroy_source, actor: :administrator, status: :succeeded, params: { id: id })
    redirect_to sources_url, notice: 'Source was successfully destroyed.'
  end

  private

  def set_source
    @source = Source.find(id)
  end

  def id
    params[:id]
  end

  def source_params
    params.require(:source).permit(:channel, :address)
  end
end
