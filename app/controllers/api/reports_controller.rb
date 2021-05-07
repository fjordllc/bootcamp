# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def index
    @reports = Report.list.page(params[:page])
    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?
  end

  def show
    @report = Report.find(params[:id])
    @reports = @report.user.reports.limit(5).order(reported_on: :DESC)
  end
end
