# frozen_string_literal: true

class API::ReportPresetsController < API::BaseController
  before_action :set_report_preset, only: %i[update]

  def create
    @template = ReportPreset.new(report_preset_params)
    @template.user = current_user
    if @template.save
      render json: { id: @template.id }, status: :ok
    else
      head :bad_request
    end
  end

  def update
    if @template.update(report_preset_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def report_preset_params
    params.require(:report_preset).permit(:description)
  end

  def set_report_preset
    @template = current_user.report_preset
  end
end
