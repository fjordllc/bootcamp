# frozen_string_literal: true

require 'test_helper'

class PjordProductReviewJobTest < ActiveJob::TestCase
  test 'creates product review comment by pjord' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review, 'レビュー本文') do
      assert_difference -> { product.comments.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end

    comment = product.comments.order(:created_at).last
    assert_equal users(:pjord), comment.user
    assert_equal 'レビュー本文', comment.description
  end

  test 'does nothing when product is missing' do
    Pjord::ProductReviewAgent.stub(:review, ->(_product) { raise 'should not be called' }) do
      assert_no_difference 'Comment.count' do
        PjordProductReviewJob.perform_now(product_id: Product.maximum(:id).to_i + 1)
      end
    end
  end

  test 'does nothing when practice disables Pjord review' do
    product = products(:product8)
    product.practice.update!(disable_pjord_review: true)

    Pjord::ProductReviewAgent.stub(:review, ->(_product) { raise 'should not be called' }) do
      assert_no_difference -> { product.comments.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end

  test 'does nothing when pjord user is missing' do
    product = products(:product8)

    Pjord.stub(:user, nil) do
      Pjord::ProductReviewAgent.stub(:review, ->(_product) { raise 'should not be called' }) do
        assert_no_difference 'Comment.count' do
          PjordProductReviewJob.perform_now(product_id: product.id)
        end
      end
    end
  end

  test 'does nothing when product review is blank' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review, '') do
      assert_no_difference -> { product.comments.reload.count } do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end

  test 'raises unexpected errors' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review, ->(_product) { raise StandardError, 'unexpected' }) do
      assert_raises(StandardError) do
        PjordProductReviewJob.perform_now(product_id: product.id)
      end
    end
  end
end
