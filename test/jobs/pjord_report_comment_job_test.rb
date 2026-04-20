# frozen_string_literal: true

require 'test_helper'

class PjordReportCommentJobTest < ActiveJob::TestCase
  test 'creates a comment by pjord when report has a question' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord.stub(:respond, 'ヒントをあげるね！') do
      assert_difference 'Comment.count', 1 do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end

    comment = Comment.last
    assert_equal pjord, comment.user
    assert_equal report, comment.commentable
    assert_equal 'ヒントをあげるね！', comment.description
  end

  test 'does not create a comment when response is the no_question marker' do
    report = reports(:report1)

    Pjord.stub(:respond, '[NO_QUESTION]') do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'does not create a comment when response is the no_question marker with backticks' do
    report = reports(:report1)

    Pjord.stub(:respond, '`[NO_QUESTION]`') do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'does not create a comment for common "no question" paraphrases' do
    report = reports(:report1)

    [
      '質問なし',
      '質問はありません。',
      '質問は特にありません',
      '質問的な内容は見当たりません。',
      '日報中に質問はないですね。',
      '日報に質問はありません'
    ].each do |phrase|
      Pjord.stub(:respond, phrase) do
        assert_no_difference 'Comment.count', "should skip: #{phrase}" do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'creates a comment when response contains no_question_marker in middle of text' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord.stub(:respond, 'この問題は質問なしでも解決できます。') do
      assert_difference 'Comment.count', 1 do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end

    assert_equal pjord, Comment.last.user
  end

  test 'does nothing when report is not found' do
    assert_no_difference 'Comment.count' do
      PjordReportCommentJob.perform_now(report_id: 0)
    end
  end

  test 'does nothing when pjord user is not found' do
    report = reports(:report1)

    Pjord.stub(:user, nil) do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'does nothing when response is blank' do
    report = reports(:report1)

    Pjord.stub(:respond, nil) do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'rescues errors from Pjord.respond' do
    report = reports(:report1)
    error_respond = ->(**_args) { raise StandardError, 'API error' }

    Pjord.stub(:respond, error_respond) do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'includes context with location and sender' do
    report = reports(:report1)

    captured_context = nil
    mock_respond = lambda { |message:, context:, instructions: nil| # rubocop:disable Lint/UnusedBlockArgument
      captured_context = context
      '[NO_QUESTION]'
    }

    Pjord.stub(:respond, mock_respond) do
      PjordReportCommentJob.perform_now(report_id: report.id)
    end

    assert_equal '日報', captured_context[:location]
    assert_equal report.user.login_name, captured_context[:sender_login_name]
  end
end
