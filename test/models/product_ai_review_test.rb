# frozen_string_literal: true

require 'test_helper'

class ProductAiReviewTest < ActiveJob::TestCase
  test 'published create prepares a private review and queues generation' do
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product = Product.create!(user: users(:kimura), practice: practices(:practice5), body: '提出本文')
      assert_equal 'pending', product.reload.product_ai_review.status
      assert_nil product.product_ai_review.content
    end
  end

  test 'WIP create and edits do not queue generation' do
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      product = Product.create!(user: users(:kimura), practice: practices(:practice5), body: '下書き', wip: true)
      product.update!(body: '下書き修正')
      assert_nil product.reload.product_ai_review
    end
  end

  test 'submission and body changes invalidate old content and renew generation' do
    product = products(:product5)
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(wip: false)
    end
    review = product.reload.product_ai_review
    generation = review.generation
    review.update!(status: 'completed', content: '古い支援', generated_at: Time.current)

    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(body: '修正後の本文')
    end
    assert_nil review.reload.content
    assert_nil review.generated_at
    assert_equal 'pending', review.status
    assert_not_equal generation, review.generation
  end

  test 'unchanged body checker and comment updates do not invalidate or queue review' do
    product = products(:product8)
    product.update!(body: '提出本文')
    review = product.reload.product_ai_review
    review.update!(status: 'completed', content: '最新の支援')
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      product.save!
      product.update!(checker: users(:mentormentaro))
      product.update!(commented_at: Time.current)
      product.comments.create!(user: users(:mentormentaro), description: '人間のコメント')
      review.update!(generated_at: Time.current)
    end
    assert_equal '最新の支援', review.reload.content
  end

  test 'body update clears content completed by another instance after review was cached' do
    product = products(:product8)
    product.update!(body: '提出本文')
    review = product.reload.product_ai_review
    ProductAiReview.find(review.id).update!(status: 'completed', content: '以前の本文への支援', generated_at: Time.current)

    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(body: '新しい提出本文')
    end

    assert_equal 'pending', review.reload.status
    assert_nil review.content
    assert_nil review.generated_at
  end

  test 'returning to WIP clears review and makes completed review unavailable' do
    product = products(:product8)
    product.update!(body: '提出本文')
    review = product.reload.product_ai_review
    generation = review.generation
    review.update!(status: 'completed', content: '非公開支援')
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      product.update!(wip: true)
    end
    assert_nil review.reload.content
    assert_not_equal generation, review.generation
    assert_not review.current_for?(product.reload)
  end

  test 'rollback preserves previous review and queues nothing' do
    product = products(:product8)
    product.update!(body: '提出本文')
    review = product.reload.product_ai_review
    review.update!(status: 'completed', content: '保存済み支援')
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
    product.update!(body: '提出本文')
    review_id = product.reload.product_ai_review.id
    product.destroy!
    assert_not ProductAiReview.exists?(review_id)
  end
end
