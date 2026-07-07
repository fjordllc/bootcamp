# frozen_string_literal: true

require 'test_helper'

class PjordProductReviewJobTest < ActiveJob::TestCase
  test 'creates product review comment by pjord' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review_result, { body: 'レビュー本文', auto_check: false }) do
      assert_difference -> { product.comments.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end

    comment = product.comments.order(:created_at).last
    assert_equal users(:pjord), comment.user
    assert_equal 'レビュー本文', comment.description
  end

  test 'does nothing when product is missing' do
    Pjord::ProductReviewAgent.stub(:review_result, ->(_product) { raise 'should not be called' }) do
      assert_no_difference 'Comment.count' do
        PjordProductReviewJob.perform_now(product_id: Product.maximum(:id).to_i + 1)
      end
    end
  end

  test 'does nothing when practice does not enable Pjord review' do
    product = products(:product8)
    product.practice.update!(pjord_review: false)

    Pjord::ProductReviewAgent.stub(:review_result, ->(_product) { raise 'should not be called' }) do
      assert_no_difference -> { product.comments.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end

  test 'does nothing when pjord user is missing' do
    product = products(:product8)

    Pjord.stub(:user, nil) do
      Pjord::ProductReviewAgent.stub(:review_result, ->(_product) { raise 'should not be called' }) do
        assert_no_difference 'Comment.count' do
          PjordProductReviewJob.perform_now(product_id: product.id)
        end
      end
    end
  end

  test 'does nothing when product review is blank' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review_result, { body: '', auto_check: false }) do
      assert_no_difference -> { product.comments.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end

  test 'checks product by Pjord when practice enables Pjord auto check and review permits it' do
    product = products(:product8)
    product.practice.update!(pjord_auto_check: true)

    Pjord::ProductReviewAgent.stub(:review_result, { body: '確認してOKにしました。', auto_check: true }) do
      assert_difference -> { product.comments.reload.count } => 1,
                        -> { product.checks.reload.count } => 1 do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end

    check = product.checks.last
    assert_equal users(:pjord), check.user
    assert_equal 'complete', product.learning.reload.status
  end

  test 'does not check product when practice disables Pjord auto check' do
    product = products(:product8)
    product.practice.update!(pjord_auto_check: false)

    Pjord::ProductReviewAgent.stub(:review_result, { body: '確認してOKにしました。', auto_check: true }) do
      assert_no_difference -> { product.checks.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end

  test 'does not check product when Pjord review does not permit auto check' do
    product = products(:product8)
    product.practice.update!(pjord_auto_check: true)

    Pjord::ProductReviewAgent.stub(:review_result, { body: '確認しました。', auto_check: false }) do
      assert_no_difference -> { product.checks.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end

  test 'does not notify when Pjord check already exists' do
    product = products(:product8)
    product.practice.update!(pjord_auto_check: true)
    Check.create!(user: users(:pjord), checkable: product)
    check_create_count = 0

    ActiveSupport::Notifications.subscribed(->(*) { check_create_count += 1 }, 'check.create') do
      Pjord::ProductReviewAgent.stub(:review_result, { body: '確認してOKにしました。', auto_check: true }) do
        assert_no_difference -> { product.checks.reload.count } do
          PjordProductReviewJob.perform_now(product_id: product.id)
        end
      end
    end

    assert_equal 0, check_create_count
  end

  test 'raises unexpected errors' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review_result, ->(_product) { raise StandardError, 'unexpected' }) do
      assert_raises(StandardError) do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end
end
