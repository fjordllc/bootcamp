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

  test 'body update followed by checker update queues once after transaction commit' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '保存済み支援')
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      Product.transaction do
        assert_no_enqueued_jobs only: ProductAiReviewJob do
          product.update!(body: '新しい本文')
          product.update!(checker: users(:mentormentaro))
        end
        assert_nil review.reload.content
      end
    end
    assert_enqueued_with(job: ProductAiReviewJob, args: [product.id])
    assert_nil review.reload.content
  end

  test 'two body updates queue once for the final body after transaction commit' do
    product = products(:product8)
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      Product.transaction do
        assert_no_enqueued_jobs only: ProductAiReviewJob do
          product.update!(body: '途中の本文')
          product.update!(body: '最終の本文')
        end
      end
    end
    assert_enqueued_with(job: ProductAiReviewJob, args: [product.id])
    assert_equal '最終の本文', product.reload.body
  end

  test 'body update followed by WIP change queues nothing after transaction commit' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '保存済み支援')
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      Product.transaction do
        product.update!(body: '下書きに戻す本文')
        product.update!(wip: true)
      end
    end
    assert_nil review.reload.content
  end

  test 'queue failure after transaction commit does not prevent saving the submission' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '保存済み支援')
    enqueue_attempts = 0
    logs = []
    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      ProductAiReviewJob.stub(:perform_later, lambda { |*|
        enqueue_attempts += 1
        raise StandardError, '保存される本文 保存済み支援 https://user:secret@example.com'
      }) do
        Product.transaction do
          product.update!(body: '保存される本文')
          product.update!(checker: users(:mentormentaro))
          assert_equal 0, enqueue_attempts
        end
      end
    end
    assert_equal 1, enqueue_attempts
    assert_equal '保存される本文', product.reload.body
    assert_nil review.reload.content
    assert_equal ["[ProductAiReviewJob] Enqueue failed product_id=#{product.id} failure=StandardError"], logs
  end

  test 'false enqueue return logs failure without preventing saving the submission' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '保存済み支援')
    logs = []
    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      ProductAiReviewJob.stub(:perform_later, false) do
        product.update!(body: '保存される本文')
      end
    end
    assert_equal '保存される本文', product.reload.body
    assert_nil review.reload.content
    assert_equal ["[ProductAiReviewJob] Enqueue failed product_id=#{product.id} failure=false"], logs
  end

  test 'rollback preserves previous review and queues nothing' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '保存済み支援')
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      Product.transaction do
        product.update!(body: '保存されない修正')
        product.update!(checker: users(:mentormentaro))
        raise ActiveRecord::Rollback
      end
    end
    assert_equal '保存済み支援', review.reload.content
  end

  test 'rollback and commit do not suppress later generation on the same instance' do
    product = products(:product8)
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      Product.transaction do
        product.update!(body: '保存されない修正')
        raise ActiveRecord::Rollback
      end
    end
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      Product.transaction do
        product.update!(body: '途中の本文')
        product.update!(body: '保存される本文')
      end
    end
    assert_enqueued_jobs 1, only: ProductAiReviewJob do
      product.update!(body: '次の本文')
    end
  end

  test 'destroy removes private review' do
    product = products(:product8)
    review = product.create_product_ai_review!(content: '非公開支援')
    product.destroy!
    assert_not ProductAiReview.exists?(review.id)
  end
end
