# frozen_string_literal: true

require 'test_helper'

class ActivityNotifierTest < ActiveSupport::TestCase
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

  test '#graduated' do
    notification = ActivityNotifier.graduated(@params)

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
      sender: users(:hajime),
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
end
