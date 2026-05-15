# frozen_string_literal: true

require 'test_helper'

class PjordReportCommentJobTest < ActiveJob::TestCase
  test 'creates a comment and an eyes reaction when intent is question' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord.stub(:classify_report, { intent: 'question', reason: '質問あり' }) do
      Pjord.stub(:respond, 'ヒントをあげますね。') do
        assert_difference -> { Comment.count } => 1,
                          -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count } => 1 do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end

    comment = Comment.last
    assert_equal pjord, comment.user
    assert_equal report, comment.commentable
    assert_equal 'ヒントをあげますね。', comment.description
  end

  test 'does not duplicate eyes reaction when pjord already reacted to the report' do
    report = reports(:report1)
    pjord = users(:pjord)
    Reaction.create!(user: pjord, reactionable: report, kind: :eyes)

    Pjord.stub(:classify_report, { intent: 'question', reason: '質問あり' }) do
      Pjord.stub(:respond, 'ヒントをあげますね。') do
        assert_difference 'Comment.count', 1 do
          assert_no_difference -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count } do
            PjordReportCommentJob.perform_now(report_id: report.id)
          end
        end
      end
    end
  end

  test 'creates a comment when intent is struggling' do
    report = reports(:report1)

    Pjord.stub(:classify_report, { intent: 'struggling', reason: '落ち込み' }) do
      Pjord.stub(:respond, '少しずつで大丈夫です。') do
        assert_difference 'Comment.count', 1 do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'creates a comment when intent is celebration' do
    report = reports(:report1)

    Pjord.stub(:classify_report, { intent: 'celebration', reason: '達成' }) do
      Pjord.stub(:respond, 'おめでとうございます！') do
        assert_difference 'Comment.count', 1 do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'does not create a comment or reaction when intent is none' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord.stub(:classify_report, { intent: 'none', reason: '通常の学習記録' }) do
      assert_no_difference ['Comment.count',
                            -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count }] do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'propagates error when classification returns nil so ActiveJob can retry' do
    report = reports(:report1)

    Pjord.stub(:classify_report, nil) do
      assert_no_difference 'Comment.count' do
        assert_raises(StandardError) do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'passes intent-specific instructions to respond' do
    report = reports(:report1)

    captured_instructions = nil
    mock_respond = lambda { |message:, context:, instructions: nil| # rubocop:disable Lint/UnusedBlockArgument
      captured_instructions = instructions
      '共感のコメント'
    }

    Pjord.stub(:classify_report, { intent: 'struggling', reason: '疲れている' }) do
      Pjord.stub(:respond, mock_respond) do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end

    assert_includes captured_instructions, '共感'
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

  test 'does not create a comment or reaction when response is blank' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord.stub(:classify_report, { intent: 'question', reason: '質問あり' }) do
      Pjord.stub(:respond, nil) do
        assert_no_difference ['Comment.count',
                              -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count }] do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'propagates errors from classify_report so ActiveJob can retry' do
    report = reports(:report1)
    error_classify = ->(**_args) { raise StandardError, 'API error' }

    Pjord.stub(:classify_report, error_classify) do
      assert_no_difference 'Comment.count' do
        assert_raises(StandardError) do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'propagates errors from respond so ActiveJob can retry' do
    report = reports(:report1)
    error_respond = ->(**_args) { raise StandardError, 'API error' }

    Pjord.stub(:classify_report, { intent: 'question', reason: '質問あり' }) do
      Pjord.stub(:respond, error_respond) do
        assert_no_difference 'Comment.count' do
          assert_raises(StandardError) do
            PjordReportCommentJob.perform_now(report_id: report.id)
          end
        end
      end
    end
  end

  test 'includes context with location and sender' do
    report = reports(:report1)

    captured_context = nil
    mock_respond = lambda { |message:, context:, instructions: nil| # rubocop:disable Lint/UnusedBlockArgument
      captured_context = context
      'コメント'
    }

    Pjord.stub(:classify_report, { intent: 'question', reason: '質問あり' }) do
      Pjord.stub(:respond, mock_respond) do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end

    assert_equal '日報', captured_context[:location]
    assert_equal report.user.login_name, captured_context[:sender_login_name]
  end
end
