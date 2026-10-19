# frozen_string_literal: true

class UserMicroReportPagination
  def initialize(user)
    @user = user
  end

  def latest_micro_report_page(per_page: 25)
    [@user.micro_reports.page.per(per_page).total_pages, 1].max
  end
end
