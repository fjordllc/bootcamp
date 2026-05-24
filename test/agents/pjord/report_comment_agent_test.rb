# frozen_string_literal: true

require 'test_helper'

class Pjord::ReportCommentAgentTest < ActiveSupport::TestCase
  test '.comment asks with report and intent context' do
    report = reports(:report1)
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal 'コメント本文', Pjord::ReportCommentAgent.comment(report, intent: 'struggling')
    end

    assert_includes chat.instructions, 'あなたはFJORD BOOT CAMP'
    assert_includes chat.instructions, 'ネガティブな感情'
    assert_includes chat.instructions, report.user.login_name
    assert_includes chat.asked_message, report.title
    assert_includes chat.asked_message, report.description
  end

  class AgentChatFake
    attr_reader :asked_message, :instructions

    def with_instructions(instructions)
      @instructions = instructions
      self
    end

    def with_tools(*)
      self
    end

    def with_schema(*)
      self
    end

    def ask(message, with: nil) # rubocop:disable Lint/UnusedMethodArgument
      @asked_message = message
      Struct.new(:content).new({ body: 'コメント本文' })
    end
  end
end
