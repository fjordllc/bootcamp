# frozen_string_literal: true

require 'test_helper'

class Reports::PjordReportCommentTest < ActionDispatch::IntegrationTest
  test 'mentor can manually enqueue report comment by Pjord' do
    report = reports(:report5)

    assert_enqueued_with(job: PjordReportCommentJob, args: [{ report_id: report.id }]) do
      post comment_by_pjord_report_path(report, _login_name: 'mentormentaro')
    end

    assert_redirected_to report_path(report)
  end

  test 'admin can manually enqueue report comment by Pjord' do
    report = reports(:report5)

    assert_enqueued_with(job: PjordReportCommentJob, args: [{ report_id: report.id }]) do
      post comment_by_pjord_report_path(report, _login_name: 'adminonly')
    end

    assert_redirected_to report_path(report)
  end

  test 'student cannot manually enqueue report comment by Pjord' do
    assert_no_enqueued_jobs only: PjordReportCommentJob do
      post comment_by_pjord_report_path(reports(:report5), _login_name: 'kimura')
    end
  end
end
