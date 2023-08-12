# frozen_string_literal: true

require 'test_helper'

class ProductReviewingNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test '#call' do
    product = products(:product73)

    assert_difference -> { Notification.count }, 1 do
      perform_enqueued_jobs do
        ProductReviewingNotifier.new.call(product)
      end
    end
  end

  test 'does not notify when checker_id is nil' do
    product = products(:product72)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifier.new.call({ product:, current_user: product.user })
    end
  end
end
