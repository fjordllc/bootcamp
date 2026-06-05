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

    assert_equal [BootcampSearchTool, UserInfoTool, ExternalContentTool], chat.tools
    assert_equal PjordResponse, chat.schema
    asked_message = chat.asked_message
    assert_includes asked_message, product.user.login_name
    assert_includes asked_message, product.practice.title
    assert_includes asked_message, product.practice.goal
    assert_includes asked_message, product.body
    assert_includes asked_message, product.practice.submission_answer.description
    assert_includes asked_message, products(:product15).body
    assert_includes chat.instructions, 'あなたはFJORD BOOT CAMP'
    assert_includes chat.instructions, '語尾に「ピヨ」など特徴的な語尾は付けず'
    assert_includes chat.instructions, '提出物にレビューコメントを書いてください。'
    assert_includes chat.instructions, '「確認しますね」「レビューしますね」のような予告や挨拶だけで終わらせず'
    assert_includes chat.instructions, 'external_content_toolを使って内容を確認してからレビューしてください。'
  end

  test '.review retries when response does not review the product content' do
    product = products(:product1)
    chat = ProductReviewChatFake.new(responses: ['提出物を確認しますね！', '本文の構成が整理されていることを確認しました。'])

    RubyLLM.stub(:chat, chat) do
      assert_equal '本文の構成が整理されていることを確認しました。', Pjord::ProductReviewAgent.review(product)
    end

    assert_equal 2, chat.asked_messages.size
    assert_includes chat.asked_messages.second, '直前のレビューコメントは提出物の内容に触れていないため不十分です。'
    assert_includes chat.asked_messages.second, '提出物を確認しますね！'
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
    attr_reader :asked_messages, :instructions, :schema, :tools

    def initialize(responses: ['レビュー本文'])
      @tools = []
      @responses = responses
      @last_response = nil
      @asked_messages = []
    end

    def asked_message = asked_messages.last

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
      @asked_messages << message
      @attachments = with
      @last_response = @responses.shift || @last_response
      Struct.new(:content).new({ body: @last_response })
    end
  end
end
