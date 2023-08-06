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

    perform_enqueued_jobs do
      ProductReviewingNotifier.new.call(product)
    end

    assert Notification.where(user_id: product.user.id, sender_id: product.checker.id,
                              message: "プラクティス「#{product.practice.title}」の提出物がレビュー中になりました（担当メンター #{product.checker_name}）。").exists?
  end
end
