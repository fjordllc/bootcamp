# frozen_string_literal: true

class Users::MicroReports::MicroReportComponent < ViewComponent::Base
  def initialize(user:, micro_report:)
    @user = user
    @micro_report = micro_report
  end

  def posted_datetime
    time = @micro_report.created_at
    if time.to_date == Time.zone.today
      "今日 #{time.strftime('%H:%M')}"
    elsif time.to_date == Time.zone.yesterday
      "昨日 #{time.strftime('%H:%M')}"
    else
      time.strftime('%Y/%m/%d %H:%M')
    end
  end
end
