# frozen_string_literal: true

require 'test_helper'

class Pjord::QuestionAnswerAgentTest < ActiveSupport::TestCase
  test 'inherits Pjord::Agent' do
    assert_operator Pjord::QuestionAnswerAgent, :<, Pjord::Agent
  end

  test '.answer asks with question context' do
    question = questions(:question1)
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal '回答本文', Pjord::QuestionAnswerAgent.answer(question)
    end

    assert_includes chat.instructions, 'あなたはFJORD BOOT CAMP'
    assert_includes chat.instructions, 'Q&A回答の指示'
    assert_includes chat.instructions, question.practice.title
    assert_includes chat.asked_message, question.title
    assert_includes chat.asked_message, question.description
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
      Struct.new(:content).new({ body: '回答本文' })
    end
  end
end
