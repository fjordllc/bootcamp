module ReportsHelper
  def recent_reports
    @reports = Report.order(updated_at: :desc, id: :desc).limit(10)
  end
end
