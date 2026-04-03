# frozen_string_literal: true

class PjordReportCommenter
  def call(_name, _started, _finished, _unique_id, payload)
    report = payload[:report]
    return unless report.first_public?

    PjordReportCommentJob.perform_later(report_id: report.id)
  end
end
