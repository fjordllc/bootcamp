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
    watch = watches(:practice1_watch_mentormentaro)
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1)
    )
    product.save!

    payload = { product: }
    perform_enqueued_jobs do
      ProductNotifierForPracticeWatcher.new.call(
        'product_create',
        Time.current,
        Time.current,
        'unique_id',
        payload
      )
    end
    assert Notification.where(user_id: watch.user_id, sender_id: product.user_id,
                              message: "#{product.user.login_name}さんが「#{product.practice.title}」の提出物を提出しました。").exists?
  end
end
