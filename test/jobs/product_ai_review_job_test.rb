# frozen_string_literal: true

require 'test_helper'

class ProductAiReviewJobTest < ActiveJob::TestCase
  setup do
    @product = products(:product8)
    @product.update!(body: 'レビューする本文')
    @review = @product.reload.product_ai_review
    @generation = @review.generation
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
    assert_equal 'completed', @review.reload.status
    assert_equal '支援内容', @review.content
    assert_not_nil @review.generated_at
    assert_equal 'claude-opus-5-5', @review.model
  end

  test 'outdated jobs do not invoke the model' do
    @product.update!(body: '最新本文')
    ProductReviewAgent.stub(:review, ->(*) { flunk 'old generation called model' }) { perform_review }
    assert_nil @review.reload.content
    assert_equal 'pending', @review.status
  end

  test 'in flight result does not replace newer pending review' do
    ProductReviewAgent.stub(:review, lambda { |*, **|
      @product.update!(body: 'さらに新しい本文')
      '古い結果'
    }) { perform_review }
    assert_nil @review.reload.content
    assert_equal 'pending', @review.status
    assert_not_equal @generation, @review.generation
  end

  test 'duplicate job cannot invoke model while another job is generating or after completion' do
    calls = 0
    ProductReviewAgent.stub(:review, lambda { |*, **|
      calls += 1
      perform_review
      '最新結果'
    }) do
      perform_review
      perform_review
    end
    assert_equal 1, calls
    assert_equal '最新結果', @review.reload.content
  end

  test 'WIP change during generation cannot publish result' do
    ProductReviewAgent.stub(:review, lambda { |*, **|
      @product.update!(wip: true)
      '古い結果'
    }) { perform_review }
    assert_nil @review.reload.content
    assert_equal 'cancelled', @review.status
  end

  test 'deleted product is ignored' do
    @product.destroy!
    ProductReviewAgent.stub(:review, ->(*) { flunk 'deleted product called model' }) { perform_review }
    assert_not ProductAiReview.exists?(@review.id)
  end

  test 'missing key produces understandable private configuration status' do
    RubyLLM.config.anthropic_api_key = nil
    ProductReviewAgent.stub(:review, ->(*) { flunk 'unconfigured model called' }) { perform_review }
    assert_equal 'unconfigured', @review.reload.status
    assert_nil @review.content
    assert_no_enqueued_jobs only: ProductAiReviewJob
  end

  test 'blank result fails privately' do
    ProductReviewAgent.stub(:review, '  ') { perform_review }
    assert_equal 'failed', @review.reload.status
    assert_nil @review.content
  end

  test 'model errors retry with no raw error content and exhaust to failed' do
    ProductReviewAgent.stub(:review, ->(*, **) { raise StandardError, 'secret learner data and API key' }) do
      assert_enqueued_jobs 1, only: ProductAiReviewJob do
        perform_review
      end
      assert_equal 'pending', @review.reload.status
      job = ProductAiReviewJob.new(product_id: @product.id, generation: @generation)
      job.executions = 2
      assert_no_enqueued_jobs only: ProductAiReviewJob do
        job.perform_now
      end
    end
    assert_equal 'failed', @review.reload.status
    assert_nil @review.content
    assert_not_includes @review.attributes.values.join, 'secret learner data'
  end

  test 'input context change during generation prevents stale completion' do
    ProductReviewAgent.stub(:review, lambda { |*, **|
      @product.practice.update!(goal: '新しい目標')
      '古い目標の結果'
    }) { perform_review }
    assert_nil @review.reload.content
    assert_not @review.current_for?(@product.reload)
  end

  private

  def perform_review
    ProductAiReviewJob.perform_now(product_id: @product.id, generation: @generation)
  end
end
