# frozen_string_literal: true

require 'test_helper'

class ActivityDeliveryTest < ActiveSupport::TestCase
  test '.notify(:graduated)' do
    params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      receiver: users(:komagata),
      link: '/example',
      read: false
    }

    Notification.create!(
      kind: Notification.kinds['graduated'],
      user: users(:komagata),
      sender: users(:kimura),
      link: "/users/#{users(:kimura).id}",
      message: "#{users(:kimura).login_name}さんがxxxxを確認しました。",
      read: false
    )

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:graduated, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:graduated, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:graduated)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:graduated)
    end
  end

  test '.notify(:comebacked)' do
    params = {
      sender: users(:kimura),
      receiver: users(:komagata)
    }

    Notification.create!(
      kind: Notification.kinds['comebacked'],
      user: users(:komagata),
      sender: users(:kimura),
      link: "/users/#{users(:kimura).id}",
      message: "#{users(:kimura).login_name}さんが休会から復帰しました！",
      read: false
    )
    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:comebacked, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:comebacked, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:comebacked)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:comebacked)
    end
  end
end
