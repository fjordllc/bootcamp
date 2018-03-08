module ReportsHelper
  def recent_reports
    @recent_reports ||= Report.eager_load(:user, :checks).order(updated_at: :desc, id: :desc).limit(15)
  end
end
