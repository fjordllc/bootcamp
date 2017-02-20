module ReportsHelper
  def recent_reports
    if @_recent_reports
      @_recent_reports
    else
      @_recent_reports = Report.order(updated_at: :desc, id: :desc).limit(10)
    end
  end

  def report_title(report_id)
    Report.find(report_id).title
  end
end
