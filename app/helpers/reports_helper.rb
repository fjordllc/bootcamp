module ReportsHelper
  def recent_reports
    @reports = Report.limit(10).order(updated_at: :desc, id: :desc)
  end
end
