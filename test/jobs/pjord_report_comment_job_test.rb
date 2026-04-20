# frozen_string_literal: true

require 'test_helper'

class PjordReportCommentJobTest < ActiveJob::TestCase
  class FakeChat
    def initialize(tool, behavior)
      @tool = tool
      @behavior = behavior
    end

    def ask(_message)
      @behavior.call(@tool)
      Struct.new(:content).new(nil)
    end
  end

  def stub_pjord_with(behavior, &block)
    stub = lambda { |context:, instructions:, extra_tools:| # rubocop:disable Lint/UnusedBlockArgument
      FakeChat.new(extra_tools.first, behavior)
    }
    Pjord.stub(:build_chat, stub, &block)
  end

  test 'creates a comment when tool is called with action=post' do
    report = reports(:report1)
    pjord = users(:pjord)

    behavior = ->(tool) { tool.execute(action: 'post', advice: 'ヒントをあげるね！') }

    stub_pjord_with(behavior) do
      assert_difference 'Comment.count', 1 do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end

    comment = Comment.last
    assert_equal pjord, comment.user
    assert_equal report, comment.commentable
    assert_equal 'ヒントをあげるね！', comment.description
  end

  test 'does not create a comment when tool is called with action=skip' do
    report = reports(:report1)

    behavior = ->(tool) { tool.execute(action: 'skip') }

    stub_pjord_with(behavior) do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'does not create a comment when tool is called with action=post but advice is blank' do
    report = reports(:report1)

    behavior = ->(tool) { tool.execute(action: 'post', advice: '') }

    stub_pjord_with(behavior) do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'does not create a comment when tool is never called' do
    report = reports(:report1)

    behavior = ->(_tool) {}

    stub_pjord_with(behavior) do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
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

  test 'rescues errors from chat.ask' do
    report = reports(:report1)

    behavior = ->(_tool) { raise StandardError, 'API error' }

    stub_pjord_with(behavior) do
      assert_no_difference 'Comment.count' do
        PjordReportCommentJob.perform_now(report_id: report.id)
      end
    end
  end

  test 'includes context with location and sender' do
    report = reports(:report1)

    captured_context = nil
    stub = lambda { |context:, instructions:, extra_tools:| # rubocop:disable Lint/UnusedBlockArgument
      captured_context = context
      FakeChat.new(extra_tools.first, ->(tool) { tool.execute(action: 'skip') })
    }

    Pjord.stub(:build_chat, stub) do
      PjordReportCommentJob.perform_now(report_id: report.id)
    end

    assert_equal '日報', captured_context[:location]
    assert_equal report.user.login_name, captured_context[:sender_login_name]
  end
end
