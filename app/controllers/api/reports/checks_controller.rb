# frozen_string_literal: true

class API::Reports::ChecksController < API::BaseController
  before_action :require_staff
  before_action -> { doorkeeper_authorize! :write }, if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :mentor }, if: -> { doorkeeper_token.present? }

  def create
    report_ids = params.require(:report_ids).map(&:to_i).uniq
    reports = Report.where(id: report_ids).select(:id, :user_id).index_by(&:id)
    missing_ids = report_ids - reports.keys
    return render json: { message: '日報が見つかりません。', report_ids: missing_ids }, status: :not_found if missing_ids.any?

    checked_report_ids = Check.where(checkable_type: 'Report', checkable_id: report_ids).pluck(:checkable_id)
    unchecked_reports = reports.values_at(*(report_ids - checked_report_ids))
    checks = insert_checks(unchecked_reports)
    delete_report_caches(checks, reports)

    render json: { checks: checks.map { |check| check_json(check) } }, status: :created
  end

  private

  def insert_checks(reports)
    now = Time.current
    rows = reports.map do |report|
      { user_id: current_user.id, checkable_type: 'Report', checkable_id: report.id, created_at: now, updated_at: now }
    end
    result = Check.insert_all(rows, returning: %w[id]) # rubocop:disable Rails/SkipsModelValidations
    Check.includes(:user).where(id: result.rows.flatten)
  end

  def delete_report_caches(checks, reports)
    checked_report_ids = checks.map(&:checkable_id)
    return if checked_report_ids.empty?

    Cache.delete_unchecked_report_count
    checked_report_ids.map { |report_id| reports.fetch(report_id).user_id }.uniq.each do |user_id|
      Cache.delete_user_unchecked_report_count(user_id)
    end
  end

  def require_staff
    render json: { message: '権限がありません。' }, status: :forbidden unless current_user&.staff?
  end
end
