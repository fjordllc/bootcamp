# frozen_string_literal: true

class API::ReportsController < API::BaseController
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }
  before_action :set_editable_report, only: %i[update]
  before_action :set_my_report, only: %i[destroy]

  def index
    @company = Company.find(params[:company_id]) if params[:company_id]
    @reports = Report.list.page(params[:page])
    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?
    @reports = @reports.where(user_id: params[:user_id]) if params[:user_id].present?
    @reports = @reports.limit(params[:limit].to_i) if params[:limit].present?
    @reports = @reports.joins(:user).where(users: { company_id: params[:company_id] }) if params[:company_id]
    return unless params[:target] == 'unchecked_reports'
    return head :forbidden unless current_user.admin_or_mentor?

    @reports = @reports.includes(:checks).unchecked.not_wip
  end

  def show
    @report = Report.includes(:user, :practices, :checks, comments: :user).find(params[:id])
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    canonicalize_learning_times(@report)

    if @report.save_uniquely
      ActiveSupport::Notifications.instrument('report.create', report: @report)
      render :show, status: :created
    else
      render json: { errors: @report.errors }, status: :unprocessable_entity
    end
  end

  def update
    @report.practice_ids = nil if params[:report][:practice_ids].nil?
    @report.assign_attributes(report_params)
    @report.learning_times.each(&:mark_for_destruction) if @report.no_learn
    canonicalize_learning_times(@report)

    if @report.save_uniquely
      ActiveSupport::Notifications.instrument('report.update', report: @report)
      render :show, status: :ok
    else
      render json: { errors: @report.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy
    ActiveSupport::Notifications.instrument('report.destroy', report: @report)
    render json: {}, status: :ok
  end

  private

  def report_params
    params.require(:report).permit(
      :title,
      :reported_on,
      :emotion,
      :no_learn,
      :description,
      :wip,
      practice_ids: [],
      learning_times_attributes: %i[id started_at finished_at _destroy]
    )
  end

  def set_my_report
    @report = current_user.reports.find_by(id: params[:id])
    render json: { message: '日報が見つかりません。' }, status: :not_found unless @report
  end

  def set_editable_report
    @report = current_user.mentor? ? Report.find_by(id: params[:id]) : current_user.reports.find_by(id: params[:id])
    render json: { message: '日報が見つかりません。' }, status: :not_found unless @report
  end

  def canonicalize_learning_times(report)
    return if report.reported_on.blank?

    report.learning_times.each do |learning_time|
      next if learning_time.started_at.blank? || learning_time.finished_at.blank?

      new_started_at = learning_time.started_at.change(
        year: report.reported_on.year,
        month: report.reported_on.month,
        day: report.reported_on.day
      )
      new_finished_at = learning_time.finished_at.change(
        year: report.reported_on.year,
        month: report.reported_on.month,
        day: report.reported_on.day
      )
      new_finished_at += 1.day if new_started_at > new_finished_at
      learning_time.assign_attributes(started_at: new_started_at, finished_at: new_finished_at)
    end
  end
end
