# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def index
    @company = Company.find(params[:company_id]) if params[:company_id]
    @reports = Report.list.page(params[:page])
    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?
    @reports = @reports.where(user_id: params[:user_id]) if params[:user_id].present?
    @reports = @reports.limit(params[:limit].to_i) if params[:limit].present?
    @reports = @reports.joins(:user).where(users: { company_id: params[:company_id] }) if params[:company_id]
  end
end
