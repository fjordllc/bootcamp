# frozen_string_literal: true

require 'test_helper'

class ProductAiReviewJobTest < ActiveJob::TestCase
  setup do
    @product = products(:product8)
    @original_key = RubyLLM.config.anthropic_api_key
    RubyLLM.config.anthropic_api_key = 'fictional-test-key'
    clear_enqueued_jobs
  end

  teardown do
    RubyLLM.config.anthropic_api_key = @original_key
  end

  test 'persists review privately without comments approvals or notifications' do
    ProductReviewAgent.stub(:review, '支援内容') do
      assert_no_difference ['Comment.count', 'Check.count', 'Notification.count'] do
        perform_review
      end
    end
    assert_equal '支援内容', @product.reload.product_ai_review.content
  end

  test 'updates existing review content' do
    review = @product.create_product_ai_review!(content: '以前の支援')
    ProductReviewAgent.stub(:review, '新しい支援') do
      assert_no_difference 'ProductAiReview.count' do
        perform_review
      end
    end
    assert_equal '新しい支援', review.reload.content
  end

  test 'in flight result cannot overwrite an edited submission' do
    ProductReviewAgent.stub(:review, lambda { |product|
      Product.find(product.id).update!(body: 'さらに新しい本文')
      '古い結果'
    }) { perform_review }
    assert_nil @product.reload.product_ai_review
  end

  test 'in flight result cannot overwrite a submission moved to another practice' do
    ProductReviewAgent.stub(:review, lambda { |product|
      Product.find(product.id).update!(practice: practices(:practice5))
      '古いプラクティスの結果'
    }) { perform_review }
    assert_nil @product.reload.product_ai_review
  end

  test 'WIP change during generation cannot publish result' do
    ProductReviewAgent.stub(:review, lambda { |product|
      Product.find(product.id).update!(wip: true)
      '古い結果'
    }) { perform_review }
    assert_nil @product.reload.product_ai_review
  end

  test 'deleted product is ignored' do
    @product.destroy!
    ProductReviewAgent.stub(:review, ->(*) { flunk 'deleted product called model' }) { perform_review }
  end

  test 'product deleted during generation is ignored' do
    ProductReviewAgent.stub(:review, lambda { |product|
      Product.find(product.id).destroy!
      '古い結果'
    }) { perform_review }
    assert_not ProductAiReview.exists?(product_id: @product.id)
  end

  test 'WIP product is ignored' do
    @product.update!(wip: true)
    ProductReviewAgent.stub(:review, ->(*) { flunk 'WIP product called model' }) { perform_review }
    assert_nil @product.reload.product_ai_review
  end

  test 'missing key skips generation' do
    RubyLLM.config.anthropic_api_key = nil
    ProductReviewAgent.stub(:review, ->(*) { flunk 'unconfigured model called' }) { perform_review }
    assert_nil @product.reload.product_ai_review
  end

  test 'blank result is not saved' do
    ProductReviewAgent.stub(:review, '  ') { perform_review }
    assert_nil @product.reload.product_ai_review
  end

  test 'provider failure does not save or retry or log private error text' do
    logs = StringIO.new
    ProductAiReviewJob.stub(:logger, ActiveSupport::Logger.new(logs)) do
      ProductReviewAgent.stub(:review, ->(*) { raise StandardError, 'PRIVATE_PROVIDER_ERROR' }) do
        assert_no_enqueued_jobs only: ProductAiReviewJob do
          perform_review
        end
      end
    end
    assert_nil @product.reload.product_ai_review
    assert_not_includes logs.string, 'PRIVATE_PROVIDER_ERROR'
  end

  private

  def perform_review
    ProductAiReviewJob.perform_now(@product.id)
  end
end
