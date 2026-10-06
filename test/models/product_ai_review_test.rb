# frozen_string_literal: true

require 'test_helper'

class ProductAiReviewTest < ActiveJob::TestCase
  test 'published create queues generation without creating an empty review' do
    product = nil
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product = Product.create!(user: users(:kimura), practice: practices(:practice5), body: '提出本文')
    end
    assert_enqueued_with(job: ProductAiReviewJob, args: [product.id])
    assert_nil product.reload.product_ai_review
  end

  test 'WIP create and edits do not queue generation' do
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      product = Product.create!(user: users(:kimura), practice: practices(:practice5), body: '下書き', wip: true)
      product.update!(body: '下書き修正')
      assert_nil product.reload.product_ai_review
    end
  end

  test 'submission queues generation and body changes clear previous content' do
    product = products(:product5)
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(wip: false)
    end
    review = product.create_product_ai_review!(content: '古い支援')
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(body: '修正後の本文')
    end
    assert_nil review.reload.content
  end

  test 'practice changes clear previous content and queue generation' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '古い支援')
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(practice: practices(:practice5))
    end
    assert_nil review.reload.content
  end

  test 'unchanged body checker and comment updates leave review alone' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '最新の支援')
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      product.save!
      product.update!(checker: users(:mentormentaro))
      product.update!(commented_at: Time.current)
      product.comments.create!(user: users(:mentormentaro), description: '人間のコメント')
    end
    assert_equal '最新の支援', review.reload.content
  end

  test 'body update clears review saved by another instance after association was cached' do
    product = products(:product8)
    assert_nil product.product_ai_review
    review = Product.find(product.id).create_product_ai_review!(content: '以前の本文への支援')
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(body: '新しい提出本文')
    end
    assert_nil review.reload.content
  end

  test 'returning to WIP clears review without enqueueing' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '非公開支援')
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      product.update!(wip: true)
    end
    assert_nil review.reload.content
  end

  test 'rollback preserves previous review and queues nothing' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '保存済み支援')
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      Product.transaction do
        product.update!(body: '保存されない修正')
        raise ActiveRecord::Rollback
      end
    end
    assert_equal '保存済み支援', review.reload.content
  end

  test 'destroy removes private review' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '非公開支援')
    product.destroy!
    assert_not ProductAiReview.exists?(review.id)
  end
end
