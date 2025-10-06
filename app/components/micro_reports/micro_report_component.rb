# frozen_string_literal: true

class MicroReports::MicroReportComponent < ViewComponent::Base
  def initialize(user:, current_user:, micro_report:)
    @user = user
    @current_user = current_user
    @micro_report = micro_report
  end

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

  def delete_path
    case controller.class.name
    when 'Users::MicroReportsController'
      helpers.user_micro_report_path(@user, @micro_report)
    when 'CurrentUser::MicroReportsController'
      helpers.current_user_micro_report_path(@micro_report)
    end
  end

  delegate :admin_login?, to: :helpers
end
