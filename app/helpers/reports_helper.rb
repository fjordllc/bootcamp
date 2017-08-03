module ReportsHelper
  def recent_reports
    @reports = Report.order(updated_at: :desc, id: :desc).limit(10)
  end

  def all_recent_reports
    @reports = Report.order(updated_at: :desc, id: :desc).limit(16)
  end
end
