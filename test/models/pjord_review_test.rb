# frozen_string_literal: true

require 'test_helper'

class PjordReviewTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'enqueues product review for newly submitted product' do
    product = products(:product8)

    assert_enqueued_with(job: PjordProductReviewJob, args: [{ product_id: product.id }]) do
      PjordReview.call(product:, wip_before_save: nil)
    end
  end

  test 'does not enqueue product review for newly saved WIP product' do
    product = products(:product5)

    assert_no_enqueued_jobs only: PjordProductReviewJob do
      PjordReview.call(product:, wip_before_save: nil)
    end
  end

  test 'enqueues product review when WIP product is submitted' do
    product = products(:product5)
    product.wip = false

    assert_enqueued_with(job: PjordProductReviewJob, args: [{ product_id: product.id }]) do
      PjordReview.call(product:, wip_before_save: true)
    end
  end

  test 'does not enqueue product review when submitted product is updated' do
    product = products(:product8)

    assert_no_enqueued_jobs only: PjordProductReviewJob do
      PjordReview.call(product:, wip_before_save: false)
    end
  end
end
