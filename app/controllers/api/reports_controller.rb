# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def index # rubocop:disable Metrics/PerceivedComplexity
    @company = Company.find(params[:company_id]) if params[:company_id]
    @reports = Report.list.page(params[:page])
    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?
    @reports = @reports.where(user_id: params[:user_id]) if params[:user_id].present?
    @reports = @reports.limit(params[:limit].to_i) if params[:limit].present?
    @reports = @reports.joins(:user).where(users: { company_id: params[:company_id] }) if params[:company_id]
    @reports = @reports.with_grant_practices if params[:with_grant] == 'true'
    return unless params[:target] == 'unchecked_reports'
    return head :forbidden unless current_user.admin_or_mentor?

    @reports = @reports.includes(:checks).unchecked.not_wip
  end
end
