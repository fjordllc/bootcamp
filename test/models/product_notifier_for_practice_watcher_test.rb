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

    ProductNotifierForPracticeWatcher.new.call(product)
    byebug
    assert Notification.where(user_id: product.user_id, sender_id: watch.user_id, body: "#{product.user}さんの提出物が更新されました").exists?
  end
end
