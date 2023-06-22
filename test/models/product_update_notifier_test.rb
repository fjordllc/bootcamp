# frozen_string_literal: true

require 'test_helper'

class ProductUpdateNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test '#call' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: users(:komagata).id
    )
    product.save!

    perform_enqueued_jobs do
      ProductUpdateNotifier.new.call({ product: product, current_user: product.user })
    end

    assert Notification.where(user_id: product.checker_id, sender_id: product.user_id,
                              message: "#{product.user.login_name}さんの提出物が更新されました").exists?
  end
end
