# frozen_string_literal: true

class PjordReportCommenter
  def call(name, _started, _finished, _unique_id, payload)
    report = payload[:report]
    return if report.wip

    case name
    when 'report.create'
      PjordReportCommentJob.perform_later(report_id: report.id)
    when 'report.update'
      return unless report.saved_change_to_attribute?(:wip, from: true)

      PjordReportCommentJob.perform_later(report_id: report.id)
    end
  end
end
