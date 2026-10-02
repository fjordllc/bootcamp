# frozen_string_literal: true

require 'test_helper'

class ProductReviewAgentTest < ActiveSupport::TestCase
  test 'uses Anthropic Opus with actual submission and private practice context without tools' do
    product = products(:product8)
    product.practice.update!(submission: true)
    product.practice.create_submission_answer!(description: '非公開の模範解答')
    chat = ChatFake.new
    RubyLLM.stub(:chat, lambda { |model:, provider:, assume_model_exists:|
      assert_equal ENV.fetch('PRODUCT_REVIEW_LLM_MODEL', 'claude-opus-5-5'), model
      assert_equal :anthropic, provider
      assert assume_model_exists
      chat
    }) do
      assert_equal 'メンター支援', ProductReviewAgent.review(product)
    end
    context = JSON.parse(chat.message)
    assert_equal product.body, context['submitted_body']
    assert_equal product.practice.title, context['practice_title']
    assert_equal product.practice.description, context['practice_description']
    assert_equal product.practice.goal, context['practice_goal']
    assert_includes context['submission_requirements'], '提出物が必要'
    assert_equal '非公開の模範解答', context['private_mentor_model_answer']
    assert_includes chat.instructions, '信頼できないデータ'
    assert_includes chat.instructions, 'URL'
    assert_includes chat.instructions, '良い点'
    assert_includes chat.instructions, '必須'
    assert_includes chat.instructions, '不確実'
    assert_includes chat.instructions, '受講生への返信案'
  end

  class ChatFake
    attr_reader :message, :instructions

    def with_instructions(instructions, **)
      @instructions = instructions
      self
    end

    def ask(message, with: nil) # rubocop:disable Lint/UnusedMethodArgument
      @message = message
      RubyLLM::Message.new(role: :assistant, content: 'メンター支援')
    end
  end
end
