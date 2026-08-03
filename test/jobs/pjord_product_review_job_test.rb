# frozen_string_literal: true

require 'test_helper'

class PjordProductReviewJobTest < ActiveJob::TestCase
  test 'does nothing for a product review job queued before feature removal' do
    product = products(:product8)

    assert_no_difference ['Comment.count', 'Check.count'] do
      PjordProductReviewJob.perform_now(product_id: product.id)
    end
  end
end
