# frozen_string_literal: true

require 'test_helper'

class ProductAiReviewerTest < ActiveSupport::TestCase
  test '.review asks latest Opus model with product review context' do
    product = products(:product1)
    mock_content = Struct.new(:content).new({ body: 'レビュー本文' })
    mock_chat = Minitest::Mock.new
    asked_message = nil
    instructions = nil

    mock_chat.expect(:with_instructions, mock_chat) do |text|
      instructions = text
      true
    end
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content) do |message|
      asked_message = message
      true
    end

    RubyLLM.stub(:chat, lambda { |model:|
      assert_equal ProductAiReviewer::MODEL, model
      mock_chat
    }) do
      assert_equal 'レビュー本文', ProductAiReviewer.review(product)
    end

    assert_includes asked_message, product.user.login_name
    assert_includes asked_message, product.practice.title
    assert_includes asked_message, product.body
    assert_includes asked_message, product.practice.submission_answer.description
    assert_includes asked_message, products(:product15).body
    assert_includes instructions, Pjord::SYSTEM_PROMPT
    assert_includes instructions, '語尾に「ピヨ」など特徴的な語尾は付けず'
    assert_includes instructions, '提出物にレビューコメントを書いてください。'
    mock_chat.verify
  end

  test '.review handles user without course' do
    product = products(:product1)
    product.user.update_column(:course_id, nil) # rubocop:disable Rails/SkipsModelValidations
    mock_content = Struct.new(:content).new({ body: 'レビュー本文' })
    mock_chat = Minitest::Mock.new
    asked_message = nil

    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content) do |message|
      asked_message = message
      true
    end

    RubyLLM.stub(:chat, mock_chat) do
      assert_equal 'レビュー本文', ProductAiReviewer.review(product)
    end

    assert_includes asked_message, '進捗率: 不明'
    mock_chat.verify
  end

  test '.review truncates long text in prompt' do
    product = products(:product1)
    product.update!(body: 'a' * (ProductAiReviewer::PROMPT_TEXT_LIMIT + 1))
    mock_content = Struct.new(:content).new({ body: 'レビュー本文' })
    mock_chat = Minitest::Mock.new
    asked_message = nil

    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content) do |message|
      asked_message = message
      true
    end

    RubyLLM.stub(:chat, mock_chat) do
      assert_equal 'レビュー本文', ProductAiReviewer.review(product)
    end

    assert_includes asked_message, 'a' * ProductAiReviewer::PROMPT_TEXT_LIMIT
    assert_not_includes asked_message, 'a' * (ProductAiReviewer::PROMPT_TEXT_LIMIT + 1)
    mock_chat.verify
  end

  test '.review includes fetched GitHub code linked from product body' do
    product = products(:product1)
    github_url = 'https://github.com/fjordllc/bootcamp/blob/main/app/models/product.rb'
    product.update!(body: "コードはこちらです。\n#{github_url}")
    mock_content = Struct.new(:content).new({ body: 'レビュー本文' })
    mock_chat = Minitest::Mock.new
    asked_message = nil

    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content) do |message|
      asked_message = message
      true
    end

    github_code = [{ url: github_url, language: 'rb', body: 'class Product < ApplicationRecord; end' }]
    ProductAiReviewer::GithubCodeFetcher.stub(:fetch, github_code) do
      RubyLLM.stub(:chat, mock_chat) do
        assert_equal 'レビュー本文', ProductAiReviewer.review(product)
      end
    end

    assert_includes asked_message, '## 提出物内のGitHubリンク先コード'
    assert_includes asked_message, "### #{github_url}"
    assert_includes asked_message, '```rb'
    assert_includes asked_message, 'class Product < ApplicationRecord; end'
    mock_chat.verify
  end

  test '.review ignores non-code GitHub links in product body' do
    product = products(:product1)
    product.update!(body: 'https://github.com/fjordllc/bootcamp/issues/1')
    mock_content = Struct.new(:content).new({ body: 'レビュー本文' })
    mock_chat = Minitest::Mock.new
    asked_message = nil

    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content) do |message|
      asked_message = message
      true
    end

    ProductAiReviewer::GithubCodeFetcher.stub(:fetch, []) do
      RubyLLM.stub(:chat, mock_chat) do
        assert_equal 'レビュー本文', ProductAiReviewer.review(product)
      end
    end

    assert_includes asked_message, "## 提出物内のGitHubリンク先コード\nなし"
    mock_chat.verify
  end
end
