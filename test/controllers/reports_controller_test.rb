# frozen_string_literal: true

require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test 'creates report after removing null bytes from title and description' do
    assert_difference -> { users(:kimura).reports.count }, 1 do
      post reports_path(_login_name: 'kimura'), params: {
        report: {
          title: "NULL\u0000バイトを含むタイトル",
          description: "NULL\u0000バイトを含む本文",
          reported_on: Date.current.to_s,
          emotion: 'positive',
          no_learn: '1'
        }
      }
    end

    report = users(:kimura).reports.find_by!(reported_on: Date.current)
    assert_redirected_to report_path(report)
    assert_equal 'NULLバイトを含むタイトル', report.title
    assert_equal 'NULLバイトを含む本文', report.description
  end

  test 'updates report after removing null bytes from title and description' do
    report = reports(:report24)

    patch report_path(report, _login_name: 'kimura'), params: {
      report: {
        title: "更新した\u0000タイトル",
        description: "更新した\u0000本文",
        reported_on: report.reported_on.to_s,
        emotion: report.emotion,
        no_learn: '1'
      }
    }

    assert_redirected_to report_path(report)
    report.reload
    assert_equal '更新したタイトル', report.title
    assert_equal '更新した本文', report.description
  end

  test 'mentor can manually create report comment by Pjord' do
    report = reports(:report5)
    report.user.update_column(:pjord_comment, false) # rubocop:disable Rails/SkipsModelValidations

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
    assert_equal 'ピヨルドがコメントしました。', flash[:notice]
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
    assert_equal 'ピヨルドがコメントしました。', flash[:notice]
    assert_equal 'コメント本文', report.comments.order(:created_at).last.description
  end

  test 'redirects with alert when Pjord report comment fails' do
    report = reports(:report5)

    PjordReportCommentJob.stub(:perform_now, ->(report_id:) { raise StandardError, report_id }) do
      assert_no_difference 'Comment.count' do
        post comment_by_pjord_report_path(report, _login_name: 'mentormentaro')
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'ピヨルドのコメントに失敗しました。時間をおいて再度お試しください。', flash[:alert]
  end

  test 'redirects with alert when Pjord report comment API key is invalid' do
    report = reports(:report5)

    PjordReportCommentJob.stub(:perform_now, lambda { |_args|
      raise RubyLLM::UnauthorizedError, 'invalid x-api-key'
    }) do
      assert_no_difference 'Comment.count' do
        post comment_by_pjord_report_path(report, _login_name: 'mentormentaro')
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'ピヨルドのAPIキー設定が無効です。管理者に確認してください。', flash[:alert]
  end

  test 'student cannot manually create report comment by Pjord' do
    assert_no_enqueued_jobs only: PjordReportCommentJob do
      assert_no_difference 'Comment.count' do
        post comment_by_pjord_report_path(reports(:report5), _login_name: 'kimura')
      end
    end
  end
end
