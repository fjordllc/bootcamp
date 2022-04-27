# frozen_string_literal: true

require 'test_helper'

class ActivityDeliveryTest < ActiveSupport::TestCase
  setup do
    @params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      receiver: users(:komagata),
      link: '/example',
      read: false
    }
  end

  test '.notify(:graduated)' do
    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 3 do
      ActivityDelivery.notify(:graduated, **@params, sync: true)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 3 do
      ActivityDelivery.notify(:graduated, **@params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 3 do
      ActivityDelivery.with(**@params).notify!(:graduated)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 3 do
      ActivityDelivery.with(**@params).notify(:graduated)
    end
  end
end
