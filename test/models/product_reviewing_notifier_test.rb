# frozen_string_literal: true

require 'test_helper'

class ProductReviewingNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#call' do
    product = products(:product72)
    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ProductReviewingNotifier.new.call(product)
    end
  end

  test 'does not notify when checker_id is nil' do
    product = products(:product73)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductReviewingNotifier.new.call(product)
    end
  end
end
