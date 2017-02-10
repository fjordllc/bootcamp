module ReportsHelper
  def recent_reports
    @reports = Report.order(updated_at: :desc, id: :desc).limit(10)
  end

  def report_title(report_id)
    title = Report.find(report_id).title
  end
end
