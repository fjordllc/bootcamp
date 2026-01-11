# frozen_string_literal: true

require 'test_helper'

class ActivityNotifierTest < ActiveSupport::TestCase
  test '#graduated' do
    params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      receiver: users(:komagata),
      link: '/example',
      read: false
    }

    notification = ActivityNotifier.graduated(params)

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#create_page' do
    @create_page_params = {
      body: 'test Docs',
      kind: :create_pages,
      sender: users(:mentormentaro),
      receiver: users(:komagata),
      link: 'pages',
      read: false,
      page: pages(:page1)
    }

    notification = ActivityNotifier.create_page(@create_page_params)

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end

    notification = ActivityNotifier.with(@create_page_params).create_page

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#first_report' do
    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityNotifier.with(report: reports(:report10), receiver: users(:kimura)).first_report.notify_now
    end
  end

  test '#hibernated' do
    notification = ActivityNotifier.with(sender: users(:kimura), receiver: users(:komagata)).hibernated

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#retired' do
    notification = ActivityNotifier.with(sender: users(:kimura), receiver: users(:komagata)).retired

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end
  end

  test '#signed_up' do
    notification = ActivityNotifier.with(sender: users(:hajime),
                                         receiver: users(:mentormentaro),
                                         # テストでは Decorator(user_decorator) のメソッドを参照できないため、user(:hajime).roles_to_s メソッドは使用せずに手動でロールを記述。
                                         sender_roles: '').signed_up

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#update_regular_event' do
    regular_event = regular_events(:regular_event1)
    notification = ActivityNotifier.with(regular_event:, receiver: users(:hatsuno), sender: regular_event.user).update_regular_event

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#no_correct_answer' do
    notification = ActivityNotifier.with(question: questions(:question8), receiver: users(:kimura)).no_correct_answer

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#moved_up_event_waiting_user' do
    notification = ActivityNotifier.with(event: events(:event3), receiver: users(:hatsuno)).moved_up_event_waiting_user

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#product_update' do
    notification = ActivityNotifier.with(product: products(:product1), receiver: users(:komagata)).product_update

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#came_inquiry' do
    params = {
      inquiry: Inquiry.first,
      sender: users(:pjord),
      receiver: users(:komagata)
    }
    notification = ActivityNotifier.with(params).came_inquiry

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end

  test '#create_organizer' do
    regular_event = regular_events(:regular_event1)
    notification = ActivityNotifier.with(regular_event:, receiver: users(:hatsuno), sender: users(:hajime)).create_organizer

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end
end
