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

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      ActivityDelivery.notify!(:graduated, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      ActivityDelivery.notify(:graduated, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      ActivityDelivery.with(**params).notify!(:graduated)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      ActivityDelivery.with(**params).notify(:graduated)
    end
  end

  test '.notify(:came_question)' do
    question = questions(:question1)
    params = {
      kind: :came_question,
      body: 'test message',
      sender: question.user,
      receiver: users(:komagata),
      question: question,
      link: '/example',
      read: false
    }

    Notification.create!(
      kind: Notification.kinds['came_question'],
      user: users(:komagata),
      sender: question.user,
      link: "/questions/#{question.id}",
      message: "#{question.user.login_name}さんから質問「#{question.title}」が投稿されました。",
      read: false
    )

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      ActivityDelivery.notify!(:came_question, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      ActivityDelivery.notify(:came_question, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      ActivityDelivery.with(**params).notify!(:came_question)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      ActivityDelivery.with(**params).notify(:came_question)
    end
  end
end
