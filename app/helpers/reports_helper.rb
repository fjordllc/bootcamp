module ReportsHelper
  def report_title(report_id)
    title = Report.find(report_id).title
  end
end
