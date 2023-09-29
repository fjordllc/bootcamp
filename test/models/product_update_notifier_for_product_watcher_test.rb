# frozen_string_literal: true

require 'test_helper'

class ProductUpdateNotifierForProductWatcherTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#call' do
    product = products(:product6)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ProductUpdateNotifierForProductWatcher.new.call({ product:, current_user: product.user })
    end
  end

  test 'does not notify when product is wip' do
    product = products(:product5)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForProductWatcher.new.call({ product:, current_user: product.user })
    end
  end

  test 'does not notify when watches and checker is nil' do
    product = products(:product73)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForProductWatcher.new.call({ product:, current_user: product.user })
    end
  end

  test 'does not notify when current_user is admin or mentor' do
    product = products(:product6)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForProductWatcher.new.call({ product:, current_user: users(:mentormentaro) })
    end
  end
end
