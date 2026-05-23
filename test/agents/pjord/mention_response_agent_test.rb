# frozen_string_literal: true

require 'test_helper'

class Pjord::MentionResponseAgentTest < ActiveSupport::TestCase
  test '.respond_to asks with mentionable context' do
    comment = comments(:comment1)
    comment.update!(description: '@pjord CSSについて教えて')
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal '返信本文', Pjord::MentionResponseAgent.respond_to(comment)
    end

    assert_includes chat.instructions, 'あなたはFJORD BOOT CAMP'
    assert_includes chat.instructions, 'メンション返信の指示'
    assert_includes chat.instructions, comment.sender.login_name
    assert_includes chat.asked_message, comment.description
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

    def ask(message, with: nil)
      @asked_message = message
      Struct.new(:content).new({ body: '返信本文' })
    end
  end
end
