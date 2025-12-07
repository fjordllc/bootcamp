# frozen_string_literal: true

require 'test_helper'

class ProductUpdateNotifierForCheckerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    AbstractNotifier::Testing::Driver.clear
  end

  test '#call' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: users(:komagata).id
    )
    product.save!

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ProductUpdateNotifierForChecker.new.call(nil, nil, nil, nil, { product:, current_user: product.user })
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

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForChecker.new.call(nil, nil, nil, nil, { product:, current_user: product.user })
    end
  end

  test 'does not notify when checker_id is nil' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: nil
    )
    product.save!

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForChecker.new.call(nil, nil, nil, nil, { product:, current_user: product.user })
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

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForChecker.new.call(nil, nil, nil, nil, { product:, current_user: users(:mentormentaro) })
    end
  end
end
