# frozen_string_literal: true

module ReportInfo
  extend ActiveSupport::Concern

  def wip_exists?
    pages.wip.exists? || reports.wip.exists? || questions.wip.exists? ||
      products.wip.exists? || announcements.wip.exists? || events.wip.exists?
  end

  def latest_micro_report_page(per_page: 25)
    [micro_reports.page.per(per_page).total_pages, 1].max
  end

  def reports_with_learning_times
    reports.joins(:learning_times).distinct.order(reported_on: :asc)
  end

  class_methods do
    def depressed_reports
      ids = User.where(
        hibernated_at: nil,
        training_completed_at: nil,
        retired_on: nil,
        graduated_on: nil,
        negative_streak: true
      ).pluck(:last_negative_report_id)
      Report.joins(:user).where(id: ids).order(reported_on: :desc)
    end
  end
end
