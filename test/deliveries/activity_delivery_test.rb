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

  test '.notify(:checked)' do
    check = checks(:procuct2_check_komagata)
    params = {
      check: check,
      receiver: check.receiver
    }

    Notification.create!(
      kind: Notification.kinds['checked'],
      user: check.receiver,
      sender: check.sender,
      link: "/products/#{check.checkable.id}",
      message: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
      read: false
    )

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:checked, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:checked, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:checked)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:checked)
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

  test '.notify(:submitted)' do
    product = products(:product6)
    params = {
      product: product,
      receiver: users(:mentormentaro)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:submitted, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:submitted, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:submitted)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:submitted)
    end
  end

  test '.notify(:retired)' do
    params = {
      sender: users(:yameo),
      receiver: users(:mentormentaro)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:retired, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:retired, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:retired)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:retired)
    end
  end

  test '.notify(:create_page)' do
    params = {
      page: pages(:page4),
      receiver: users(:mentormentaro)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:create_page, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:create_page, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:create_page)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:create_page)
    end
  end
end
