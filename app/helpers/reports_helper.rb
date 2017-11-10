module ReportsHelper
  def recent_reports
    @recent_reports ||= Report.eager_load(:user, :checks).order(updated_at: :desc, id: :desc).limit(15)
  end

  def admin_can_check_it?
    current_user.admin? && (un_checked_report? && not_report_user?)
  end

  def un_checked_report?
    !current_user.checks.find_by(report_id: params[:id])
  end

  def not_report_user?
    !(current_user == @report.user)
  end
end
