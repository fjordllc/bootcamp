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
    product = products(:product68)

    assert_difference -> { Notification.count }, 1 do
      perform_enqueued_jobs do
        ProductReviewingNotifier.new.call(product)
      end
    end
  end
end
