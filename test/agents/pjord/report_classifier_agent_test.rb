# frozen_string_literal: true

require 'test_helper'

class Pjord::ReportClassifierAgentTest < ActiveSupport::TestCase
  test '.classify returns parsed report intent' do
    report = reports(:report1)
    chat = ClassifierChatFake.new('{"intent":"question","reason":"質問がある"}')

    RubyLLM.stub(:chat, chat) do
      result = Pjord::ReportClassifierAgent.classify(report)

      assert_equal 'question', result[:intent]
      assert_equal '質問がある', result[:reason]
    end

    assert_includes chat.instructions, '日報の内容を分類'
    assert_includes chat.asked_message, report.title
    assert_includes chat.asked_message, report.description
  end

  test '.classify returns nil on invalid intent' do
    report = reports(:report1)
    chat = ClassifierChatFake.new('{"intent":"unknown","reason":"?"}')

    RubyLLM.stub(:chat, chat) do
      assert_nil Pjord::ReportClassifierAgent.classify(report)
    end
  end

  class ClassifierChatFake
    attr_reader :asked_message, :instructions

    def initialize(content)
      @content = content
    end

    def with_instructions(instructions)
      @instructions = instructions
      self
    end

    def with_schema(*)
      self
    end

    def ask(message, with: nil) # rubocop:disable Lint/UnusedMethodArgument
      @asked_message = message
      Struct.new(:content).new(@content)
    end
  end
end
