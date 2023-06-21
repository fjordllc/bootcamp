# frozen_string_literal: true

require 'test_helper'

class ProductNotifierForPracticeWatcherTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test '#call' do
    watch = Watch.new(
      user: users(:machida),
      watchable: practices(:practice1)
    )
    watch.save!

    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1)
    )
    product.save!

    product.update!(body: 'testtest')
    product.save!

    perform_enqueued_jobs do
      assert_difference 'Notification.count', 2 do
        ProductNotifierForPracticeWatcher.new.call(product)
      end
    end
  end
end
