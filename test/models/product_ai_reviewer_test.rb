# frozen_string_literal: true

require 'test_helper'

class ProductAiReviewerTest < ActiveSupport::TestCase
  test '.review asks latest Opus model with product review context' do
    product = products(:product1)
    mock_content = Struct.new(:content).new({ body: 'レビュー本文' })
    mock_chat = Minitest::Mock.new
    asked_message = nil

    mock_chat.expect(:with_instructions, mock_chat, [String])
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
end
