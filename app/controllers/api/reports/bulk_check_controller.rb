# frozen_string_literal: true

class API::Reports::BulkCheckController < API::BaseController
  before_action :require_staff
  before_action -> { doorkeeper_authorize! :write }, if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :mentor }, if: -> { doorkeeper_token.present? }

  def create
    report_ids = params.require(:report_ids).map(&:to_i).uniq
    reports = Report.includes(:checks).where(id: report_ids).index_by(&:id)
    missing_ids = report_ids - reports.keys
    return render json: { message: '日報が見つかりません。', report_ids: missing_ids }, status: :not_found if missing_ids.any?

    checks = Check.transaction do
      reports.values.filter_map do |report|
        next if report.checked?

        Check.create!(user: current_user, checkable: report).tap do |check|
          ActiveSupport::Notifications.instrument('check.create', check:)
        end
      end
    end

    render json: { checks: checks.map { |check| check_json(check) } }, status: :created
  end

  private

  def require_staff
    render json: { message: '権限がありません。' }, status: :forbidden unless current_user&.staff?
  end
end
