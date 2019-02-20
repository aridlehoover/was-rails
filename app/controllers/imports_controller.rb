class ImportsController < ApplicationController
  def create
    @import = Import.new(import_params)
    @import.file.attach(params[:import][:file])

    if @import.save
      WASLogger.json(action: :create_import, actor: :administrator, status: :succeeded, params: import_params.to_h)
      redirect_to '/', notice: 'Import saved!'
    else
      WASLogger.json(action: :create_import, actor: :administrator, status: :failed, params: import_params.to_h)
      render :new
    end
  end

  def new
    @import = Import.new
  end

  private

  def import_params
    params.require(:import).permit(:import_type)
  end
end
