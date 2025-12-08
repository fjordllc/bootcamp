# frozen_string_literal: true

require 'test_helper'

class ProductUpdateNotifierForCheckerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#call' do
    product = Product.new(
      body: 'test',
      user: users(:hajime),
      practice: practices(:practice1),
      checker_id: users(:komagata).id
    )
    product.save!

    # Debug: Check AbstractNotifier configuration
    puts "DEBUG: AbstractNotifier.delivery_mode = #{AbstractNotifier.delivery_mode}"
    puts "DEBUG: AbstractNotifier.test? = #{AbstractNotifier.test?}"
    puts "DEBUG: AbstractNotifier.noop? = #{AbstractNotifier.noop?}"
    puts "DEBUG: RAILS_ENV = #{ENV['RAILS_ENV']}"
    puts "DEBUG: enqueued_deliveries count before = #{AbstractNotifier::Testing::Driver.enqueued_deliveries.count}"

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
