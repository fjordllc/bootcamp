# frozen_string_literal: true

class Users::MicroReports::MicroReportComponent < ViewComponent::Base
  def initialize(user:, current_user:, micro_report:)
    @user = user
    @current_user = current_user
    @micro_report = micro_report
  end

  delegate :comment_user, to: :@micro_report

  def posted_datetime
    time = @micro_report.created_at
    if time.to_date == Time.zone.today
      "今日 #{l(time, format: :time_only)}"
    elsif time.to_date == Time.zone.yesterday
      "昨日 #{l(time, format: :time_only)}"
    else
      l(time, format: :date_and_time)
    end
  end

  def owner_post?
    comment_user == @user
  end
end
