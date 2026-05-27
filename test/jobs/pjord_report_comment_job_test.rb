# frozen_string_literal: true

require 'test_helper'

class PjordReportCommentJobTest < ActiveJob::TestCase
  test 'creates a comment and an eyes reaction when intent is question' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'question', reason: '質問あり' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'ヒントをあげますね。') do
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

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'question', reason: '質問あり' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'ヒントをあげますね。') do
        assert_difference 'Comment.count', 1 do
          assert_no_difference -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count } do
            PjordReportCommentJob.perform_now(report_id: report.id)
          end
        end
      end
    end
  end

  test 'still creates a comment even when reaction fails' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'question', reason: '質問あり' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'ヒントをあげますね。') do
        Reaction.stub(:find_or_create_by!, ->(**_args) { raise ActiveRecord::RecordInvalid }) do
          assert_difference 'Comment.count', 1 do
            assert_no_difference -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count } do
              assert_nothing_raised do
                PjordReportCommentJob.perform_now(report_id: report.id)
              end
            end
          end
        end
      end
    end
  end

  test 'creates a comment when intent is struggling' do
    report = reports(:report1)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'struggling', reason: '落ち込み' }) do
      Pjord::ReportCommentAgent.stub(:comment, '少しずつで大丈夫です。') do
        assert_difference 'Comment.count', 1 do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'creates a comment when intent is celebration' do
    report = reports(:report1)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'celebration', reason: '達成' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'おめでとうございます！') do
        assert_difference 'Comment.count', 1 do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'creates only an eyes reaction when intent is none' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'none', reason: '通常の学習記録' }) do
      assert_difference -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count }, 1 do
        assert_no_difference 'Comment.count' do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'does not duplicate eyes reaction when intent is none' do
    report = reports(:report1)
    pjord = users(:pjord)
    Reaction.create!(user: pjord, reactionable: report, kind: :eyes)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'none', reason: '通常の学習記録' }) do
      assert_no_difference ['Comment.count',
                            -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count }] do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'creates only an eyes reaction when classification returns nil' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord::ReportClassifierAgent.stub(:classify, nil) do
      assert_difference -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count }, 1 do
        assert_no_difference 'Comment.count' do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'passes report and intent to report comment agent' do
    report = reports(:report1)

    captured_report = nil
    captured_intent = nil
    comment = lambda { |passed_report, intent:|
      captured_report = passed_report
      captured_intent = intent
      '共感のコメント'
    }

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'struggling', reason: '疲れている' }) do
      Pjord::ReportCommentAgent.stub(:comment, comment) do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end

    assert_equal report, captured_report
    assert_equal 'struggling', captured_intent
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

  test 'creates only an eyes reaction when response is blank' do
    report = reports(:report1)
    pjord = users(:pjord)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'question', reason: '質問あり' }) do
      Pjord::ReportCommentAgent.stub(:comment, nil) do
        assert_difference -> { Reaction.where(user: pjord, reactionable: report, kind: :eyes).count }, 1 do
          assert_no_difference 'Comment.count' do
            PjordReportCommentJob.perform_now(report_id: report.id)
          end
        end
      end
    end
  end

  test 'propagates errors from classify_report so ActiveJob can retry' do
    report = reports(:report1)
    error_classify = ->(**_args) { raise StandardError, 'API error' }

    Pjord::ReportClassifierAgent.stub(:classify, error_classify) do
      assert_no_difference 'Comment.count' do
        assert_raises(StandardError) do
          PjordReportCommentJob.perform_now(report_id: report.id)
        end
      end
    end
  end

  test 'propagates errors from report comment agent so ActiveJob can retry' do
    report = reports(:report1)
    error_comment = ->(_report, intent:) { raise StandardError, 'API error' } # rubocop:disable Lint/UnusedBlockArgument

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'question', reason: '質問あり' }) do
      Pjord::ReportCommentAgent.stub(:comment, error_comment) do
        assert_no_difference 'Comment.count' do
          assert_raises(StandardError) do
            PjordReportCommentJob.perform_now(report_id: report.id)
          end
        end
      end
    end
  end
end
