# frozen_string_literal: true

module ReportInfo
  extend ActiveSupport::Concern

  def depressed?
    reported_reports = reports.order(reported_on: :desc).limit(User::DEPRESSED_SIZE)
    reported_reports.size == User::DEPRESSED_SIZE && reported_reports.all?(&:negative?)
  end

  def raw_last_negative_report_id
    reports.where(emotion: 'negative')
           .order(reported_on: :desc)
           .limit(1)
           .pluck(:id)
           .try(:first)
  end

  def update_negative_streak
    self.negative_streak = depressed?
    self.last_negative_report_id = raw_last_negative_report_id
    save!(validate: false)
  end

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
end
