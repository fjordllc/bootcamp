# frozen_string_literal: true

require 'test_helper'

class Pjord::ProductReviewAgentTest < ActiveSupport::TestCase
  test 'inherits RubyLLM::Agent' do
    assert_operator Pjord::ProductReviewAgent, :<, Pjord::Agent
  end

  test '.review asks latest Sonnet model with product review context' do
    product = products(:product1)
    chat = ProductReviewChatFake.new

    RubyLLM.stub(:chat, lambda { |model:|
      assert_equal 'claude-sonnet-4-6', model
      chat
    }) do
      assert_equal 'レビュー本文', Pjord::ProductReviewAgent.review(product)
    end

    assert_equal [BootcampSearchTool, UserInfoTool, ExternalContentTool, GithubPullRequestReviewCommentTool], chat.tools
    assert_equal PjordProductReviewResponse, chat.schema
    asked_message = chat.asked_message
    assert_includes asked_message, product.user.login_name
    assert_includes asked_message, product.practice.title
    assert_includes asked_message, product.practice.goal
    assert_includes asked_message, product.body
    assert_includes asked_message, product.practice.submission_answer.description
    assert_includes asked_message, products(:product15).body
    assert_includes chat.instructions, 'あなたはFJORD BOOT CAMP'
    assert_includes chat.instructions, 'その言語の自然で丁寧な文体で話す'
    assert_includes chat.instructions, '人間らしい文章にする'
    assert_includes chat.instructions, '提出物にレビューコメントを書いてください。'
    assert_includes chat.instructions, 'reviewed_points には、提出物本文、URL先の内容、模範解答、過去コメントなどを確認して判断した具体的な点を1つ以上入れてください。'
    assert_includes chat.instructions, '管理側への説明、内部事情、運用者向けメモ、レビュー生成方針への言及は含めず'
    assert_includes chat.instructions, 'external_content_toolを使って内容を確認してからレビューしてください。'
    assert_includes chat.instructions, 'コードの特定行に対する具体的な指摘は、可能な限りgithub_pull_request_review_comment_toolを使ってPRの該当行へ直接コメントしてください。'
  end

  test '.review handles user without course' do
    product = products(:product1)
    product.user.update_column(:course_id, nil) # rubocop:disable Rails/SkipsModelValidations
    chat = ProductReviewChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal 'レビュー本文', Pjord::ProductReviewAgent.review(product)
    end

    assert_includes chat.asked_message, '進捗率: 不明'
  end

  test '.review truncates long text in prompt' do
    product = products(:product1)
    product.update!(body: 'a' * (Pjord::ProductReviewAgent::PROMPT_TEXT_LIMIT + 1))
    chat = ProductReviewChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal 'レビュー本文', Pjord::ProductReviewAgent.review(product)
    end

    asked_message = chat.asked_message
    assert_includes asked_message, 'a' * Pjord::ProductReviewAgent::PROMPT_TEXT_LIMIT
    assert_not_includes asked_message, 'a' * (Pjord::ProductReviewAgent::PROMPT_TEXT_LIMIT + 1)
  end

  test '.review keeps GitHub links in product body for the external content tool' do
    product = products(:product1)
    github_url = 'https://github.com/fjordllc/bootcamp/blob/main/app/models/product.rb'
    product.update!(body: "コードはこちらです。\n#{github_url}")
    chat = ProductReviewChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal 'レビュー本文', Pjord::ProductReviewAgent.review(product)
    end

    asked_message = chat.asked_message
    assert_includes asked_message, github_url
    assert_not_includes asked_message, '## 提出物内のGitHubリンク先コード'
  end

  test '.review lets the external content tool decide whether a GitHub URL is useful' do
    product = products(:product1)
    product.update!(body: 'https://github.com/fjordllc/bootcamp/issues/1')
    chat = ProductReviewChatFake.new

    RubyLLM.stub(:chat, chat) do
      assert_equal 'レビュー本文', Pjord::ProductReviewAgent.review(product)
    end

    assert_includes chat.asked_message, 'https://github.com/fjordllc/bootcamp/issues/1'
    assert_not_includes chat.asked_message, '## 提出物内のGitHubリンク先コード'
  end

  class ProductReviewChatFake
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

    def ask(message, with: nil)
      @asked_message = message
      @attachments = with
      Struct.new(:content).new({ body: 'レビュー本文', reviewed_points: ['提出物本文'] })
    end
  end
end
