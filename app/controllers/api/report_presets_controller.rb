# frozen_string_literal: true

class API::ReportPresetsController < API::BaseController
  before_action :set_report_preset, only: %i[update]

  def create
    @report_preset = ReportPreset.new(report_preset_params)
    @report_preset.user = current_user
    if @report_preset.save
      render json: { id: @report_preset.id }, status: :ok
    else
      head :bad_request
    end
  end

  def update
    if @report_preset.update(report_preset_params)
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
    @report_preset = current_user.report_preset
  end
end
