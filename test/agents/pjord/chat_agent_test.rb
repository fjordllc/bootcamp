# frozen_string_literal: true

require 'test_helper'

class Pjord::ChatAgentTest < ActiveSupport::TestCase
  test 'builds a response with user context and recent messages' do
    user = users(:hajime)
    session = PjordChatSession.create!(user:)
    session.messages.create!(role: 'user', body: '前の相談')
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal '回答です', Pjord::ChatAgent.reply(
        user:,
        message: '今回の相談',
        recent_messages: session.messages
      )
    end

    assert_includes chat.asked_message, user.login_name
    assert_includes chat.asked_message, '前の相談'
    assert_includes chat.asked_message, '今回の相談'
  end

  class AgentChatFake
    attr_reader :asked_message

    def with_instructions(*)
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
      Struct.new(:content).new({ body: '回答です' })
    end
  end
end
