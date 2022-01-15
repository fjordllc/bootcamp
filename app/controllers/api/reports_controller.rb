# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def index
    @reports = Report.list.page(params[:page])
    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?
    @reports = @reports.where(user_id: params[:user_id]) if params[:user_id].present?
    @reports = @reports.limit(params[:limit].to_i) if params[:limit].present?
  end
end
