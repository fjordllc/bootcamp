# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def index
    @reports = Report.list.page(params[:page])
    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?
  end
end
