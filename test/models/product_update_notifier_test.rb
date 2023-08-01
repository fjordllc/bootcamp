# frozen_string_literal: true

require 'test_helper'

class ProductUpdateNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#call' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: users(:komagata).id
    )
    product.save!

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ProductUpdateNotifier.new.call({ product:, current_user: product.user })
    end
  end

  test 'does not notify when product is wip' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: users(:komagata).id,
      wip: true
    )
    product.save!

    assert_difference 'Notification.count', 0 do
      perform_enqueued_jobs do
        ProductUpdateNotifier.new.call({ product:, current_user: product.user })
      end
    end
  end

  test 'does not notify when checker_id is nil' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: users(:komagata).id,
      wip: true
    )
    product.save!

    assert_difference 'Notification.count', 0 do
      perform_enqueued_jobs do
        ProductUpdateNotifier.new.call({ product:, current_user: product.user })
      end
    end
  end

  test 'does not notify when current_user is admin or mentor' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: users(:komagata).id
    )
    product.save!

    assert_difference 'Notification.count', 0 do
      perform_enqueued_jobs do
        ProductUpdateNotifier.new.call({ product:, current_user: users(:mentormentaro) })
      end
    end
  end
end
