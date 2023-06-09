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

  test '.notify(:watching_notification)' do
    watch = watches(:report1_watch_kimura)
    watching = notifications(:notification_watching)
    params = {
      watchable: watch.watchable,
      receiver: watching.user,
      comment: comments(:comment1),
      sender: comments(:comment1).user
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:watching_notification, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:watching_notification, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:watching_notification)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:watching_notification)
    end
  end

  test '.notify(:assigned_as_checker)' do
    product = products(:product64)
    params = {
      product: product,
      receiver: product.checker
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:assigned_as_checker, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:assigned_as_checker, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:assigned_as_checker)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:assigned_as_checker)
    end
  end

  test '.notify(:hibernated)' do
    user = hibernations(:hibernation1).user
    params = {
      sender: user,
      receiver: users(:komagata)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:hibernated, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:hibernated, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:hibernated)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:hibernated)
    end
  end

  test '.notify(:first_report)' do
    report = reports(:report10)
    params = {
      report: report,
      receiver: users(:komagata)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:first_report, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:first_report, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:first_report)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:first_report)
    end
  end

  test '.notify(:consecutive_sad_report)' do
    params = {
      report: reports(:report22),
      receiver: users(:komagata)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:consecutive_sad_report, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:consecutive_sad_report, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:consecutive_sad_report)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:consecutive_sad_report)
    end
  end
end
