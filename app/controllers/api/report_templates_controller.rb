# frozen_string_literal: true

class API::ReportTemplatesController < API::BaseController
  before_action :set_report_template, only: %i[update]

  def create
    @template = ReportTemplate.new(report_template_params)
    @template.user = current_user
    if @template.save
      head :ok
    else
      head :bad_request
    end
  end

  def update
    if @template.update(report_template_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def report_template_params
    params.require(:report_template).permit(:description)
  end

  def set_report_template
    @template = current_user.report_template
  end
end
