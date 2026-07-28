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
    assert_includes chat.instructions, '人間らしい文章にする'
    assert_includes chat.instructions, 'external_content_toolを使って内容を確認してから返信してください。'
    assert_includes chat.instructions, 'GitHubのPR、ファイル、ディレクトリ、rawファイルへのURLが含まれる場合'
    assert_includes chat.instructions, 'CodePenや提出物のリンク先が見えない'
    assert_includes chat.instructions, 'メンターへのメンションや対応引き継ぎの依頼はしないでください。'
    assert_includes chat.instructions, 'リンク先の内容が返信に不可欠でない場合'
    assert_includes chat.instructions, 'メンションしてきたユーザーに「見られる状態にしてください」「内容を教えてください」と質問しないでください。'
    assert_includes chat.instructions, 'ピヨルドのレビューコメントに対して'
    assert_includes chat.instructions, 'body を空にして返信しないでください。'
    assert_includes chat.asked_message, comment.description
    assert_equal [BootcampSearchTool, UserInfoTool, ExternalContentTool], chat.tools
    assert_equal PjordResponse, chat.schema
  end

  test '.respond_to uses saved common and mention response prompts' do
    AiPrompt.create!(key: 'pjord', body: '保存した共通プロンプト')
    AiPrompt.create!(key: 'mention_response', body: '保存したメンション返信プロンプト')
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      Pjord::MentionResponseAgent.respond_to(comments(:comment1))
    end

    assert_includes chat.instructions, '保存した共通プロンプト'
    assert_includes chat.instructions, '保存したメンション返信プロンプト'
  end

  class AgentChatFake
    attr_reader :asked_message, :instructions, :schema, :tools

    def initialize
      @tools = []
    end

    def with_instructions(instructions)
      @instructions = instructions
      self
    end

    def with_tools(*tools)
      @tools = tools
      self
    end

    def with_schema(schema)
      @schema = schema
      self
    end

    def ask(message, with: nil) # rubocop:disable Lint/UnusedMethodArgument
      @asked_message = message
      Struct.new(:content).new({ body: '返信本文' })
    end
  end
end
