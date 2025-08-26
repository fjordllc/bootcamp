# frozen_string_literal: true

require 'test_helper'

class ProductUpdateNotifierForWatcherTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#call' do
    # watchされていて、担当のいない提出物
    product = products(:product6)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ProductUpdateNotifierForWatcher.new.call(nil, nil, nil, nil, { product:, current_user: product.user })
    end
  end

  test 'does not notify when product is wip' do
    # watchされていて、wipの提出物
    product = products(:product5)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForWatcher.new.call(nil, nil, nil, nil, { product:, current_user: product.user })
    end
  end

  test 'does not notify when watches and checker are nil' do
    # 担当者がいなくてwatchされていない提出物
    product = products(:product73)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForWatcher.new.call(nil, nil, nil, nil, { product:, current_user: product.user })
    end
  end

  test 'does not notify when current_user is admin or mentor' do
    # watchされていて、担当のいない提出物
    product = products(:product6)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      ProductUpdateNotifierForWatcher.new.call(nil, nil, nil, nil, { product:, current_user: users(:mentormentaro) })
    end
  end
end
