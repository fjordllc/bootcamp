# frozen_string_literal: true

require 'test_helper'

class Reports::PjordReportCommentTest < ActionDispatch::IntegrationTest
  test 'mentor can manually create report comment by Pjord' do
    report = reports(:report5)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'general' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'コメント本文') do
        assert_no_enqueued_jobs only: PjordReportCommentJob do
          assert_difference -> { report.comments.where(user: users(:pjord)).count }, 1 do
            post comment_by_pjord_report_path(report, _login_name: 'mentormentaro')
          end
        end
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'コメント本文', report.comments.order(:created_at).last.description
  end

  test 'admin can manually create report comment by Pjord' do
    report = reports(:report5)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'general' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'コメント本文') do
        assert_no_enqueued_jobs only: PjordReportCommentJob do
          assert_difference -> { report.comments.where(user: users(:pjord)).count }, 1 do
            post comment_by_pjord_report_path(report, _login_name: 'adminonly')
          end
        end
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'コメント本文', report.comments.order(:created_at).last.description
  end

  test 'student cannot manually create report comment by Pjord' do
    assert_no_enqueued_jobs only: PjordReportCommentJob do
      assert_no_difference 'Comment.count' do
        post comment_by_pjord_report_path(reports(:report5), _login_name: 'kimura')
      end
    end
  end
end
