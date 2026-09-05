# frozen_string_literal: true

class ReportOrder
  def initialize(report)
    @report = report
  end

  def previous
    Report.where(user: @report.user)
          .where('reported_on < ?', @report.reported_on)
          .order(reported_on: :desc)
          .first
  end

  def next
    Report.where(user: @report.user)
          .where('reported_on > ?', @report.reported_on)
          .order(:reported_on)
          .first
  end

  def first?
    serial_number == 1
  end

  def serial_number
    Report.select(:id)
          .where(user: @report.user)
          .order(:created_at)
          .index(@report) + 1
  end

  def latest_of_user?
    @report == Report.not_wip
                     .where(user: @report.user, wip: false)
                     .order(reported_on: :desc)
                     .first
  end

  def interval
    (@report.reported_on - not_wip_previous_of_user.reported_on).to_i
  end

  def not_wip_previous_of_user
    Report.where(user: @report.user, wip: false)
          .order(reported_on: :desc)
          .second
  end
end
