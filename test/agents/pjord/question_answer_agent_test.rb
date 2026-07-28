# frozen_string_literal: true

require 'test_helper'

class Pjord::QuestionAnswerAgentTest < ActiveSupport::TestCase
  test 'inherits Pjord::Agent' do
    assert_operator Pjord::QuestionAnswerAgent, :<, Pjord::Agent
  end

  test '.answer asks with question context' do
    question = questions(:question1)
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, lambda { |model:|
      assert_equal 'claude-sonnet-5', model
      chat
    }) do
      assert_equal '回答本文', Pjord::QuestionAnswerAgent.answer(question)
    end

    assert_includes chat.instructions, 'あなたはFJORD BOOT CAMP'
    assert_includes chat.instructions, 'Q&A回答の指示'
    assert_includes chat.instructions, question.practice.title
    assert_includes chat.instructions, '人間らしい文章にする'
    assert_includes chat.asked_message, question.title
    assert_includes chat.asked_message, question.description
  end

  test '.answer uses saved common and question answer prompts' do
    AiPrompt.create!(key: 'pjord', body: '保存した共通プロンプト')
    AiPrompt.create!(key: 'question_answer', body: '保存したQ&A回答プロンプト')
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      Pjord::QuestionAnswerAgent.answer(questions(:question1))
    end

    assert_includes chat.instructions, '保存した共通プロンプト'
    assert_includes chat.instructions, '保存したQ&A回答プロンプト'
    assert_includes chat.instructions, questions(:question1).where_mention
    assert_includes chat.instructions, questions(:question1).practice.title
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
