# frozen_string_literal: true

require 'test_helper'

class Pjord::ReportCommentAgentTest < ActiveSupport::TestCase
  test '.comment asks with report and intent context' do
    report = reports(:report1)
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, lambda { |model:|
      assert_equal 'claude-opus-4-6', model
      chat
    }) do
      assert_equal 'コメント本文', Pjord::ReportCommentAgent.comment(report, intent: 'struggling')
    end

    assert_includes chat.instructions, 'あなたはFJORD BOOT CAMP'
    assert_includes chat.instructions, 'ネガティブな感情'
    assert_includes chat.instructions, report.user.login_name
    assert_includes chat.instructions, '人間らしい文章にする'
    assert_includes chat.instructions, 'external_content_toolを使って内容を確認してからコメントしてください。'
    assert_includes chat.instructions, 'GitHubのPR、ファイル、ディレクトリ、rawファイルへのURLが含まれる場合'
    assert_includes chat.instructions, 'CodePenやリンク先が見えない'
    assert_includes chat.instructions, 'メンターへのメンションや対応引き継ぎの依頼はしないでください。'
    assert_includes chat.instructions, 'リンク先の内容がコメントに不可欠でない場合'
    assert_includes chat.instructions, '日報を書いたユーザーに「見られる状態にしてください」「内容を教えてください」と質問しないでください。'
    assert_includes chat.asked_message, report.title
    assert_includes chat.asked_message, report.description
    assert_equal [BootcampSearchTool, UserInfoTool, ExternalContentTool], chat.tools
    assert_equal PjordResponse, chat.schema
  end

  test '.comment uses saved common and report comment prompts' do
    AiPrompt.create!(key: 'pjord', body: '保存した共通プロンプト')
    AiPrompt.create!(key: 'report_comment', body: '保存した日報コメントプロンプト')
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      Pjord::ReportCommentAgent.comment(reports(:report1), intent: 'general')
    end

    assert_includes chat.instructions, '保存した共通プロンプト'
    assert_includes chat.instructions, '保存した日報コメントプロンプト'
    assert_includes chat.instructions, 'general'
    assert_includes chat.instructions, reports(:report1).user.login_name
  end

  test '.comment includes general intent instructions' do
    report = reports(:report1)
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      Pjord::ReportCommentAgent.comment(report, intent: 'general')
    end

    assert_includes chat.instructions, '短く自然な応援や共感'
    assert_includes chat.instructions, '無理にアドバイスを足さず'
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
      Struct.new(:content).new({ body: 'コメント本文' })
    end
  end
end
