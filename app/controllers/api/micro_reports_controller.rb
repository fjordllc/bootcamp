# frozen_string_literal: true

class API::MicroReportsController < API::BaseController
  before_action :set_micro_report, only: %i[update]

  def update
    if @micro_report.update(micro_report_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_micro_report
    @micro_report = current_user.admin? ? MicroReport.find(params[:id]) : current_user.micro_reports.find(params[:id])
  end

  def micro_report_params
    params.require(:micro_report).permit(:content)
  end
end
