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
      check:,
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
      product:,
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
      product:,
      receiver: User.find(product.checker_id)
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
      report:,
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

  test '.notify(:update_regular_event)' do
    regular_event = regular_events(:regular_event1)
    params = {
      regular_event:,
      receiver: users(:komagata)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:update_regular_event, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:update_regular_event, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:update_regular_event)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:update_regular_event)
    end
  end

  test '.notify(:signed_up)' do
    user = ActiveDecorator::Decorator.instance.decorate(User.find(users(:hajime).id))

    params = {
      sender: user,
      receiver: users(:komagata),
      sender_roles: user.roles_to_s(user:)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:signed_up, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:signed_up, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:signed_up)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:signed_up)
    end
  end

  test '.notify(:chose_correct_answer)' do
    answer = answers(:answer1)
    params = {
      answer:,
      receiver: answer.user
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:chose_correct_answer, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:chose_correct_answer, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:chose_correct_answer)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:chose_correct_answer)
    end
  end

  test '.notify(:no_correct_answer)' do
    question = questions(:question1)
    params = {
      question:,
      receiver: question.user
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:no_correct_answer, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:no_correct_answer, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:no_correct_answer)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:no_correct_answer)
    end
  end

  test '.notify(:product_update)' do
    params = {
      product: products(:product1),
      receiver: users(:komagata)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:product_update, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:product_update, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:product_update)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:product_update)
    end
  end

  test '.notify(:came_comment)' do
    comment = comments(:commentOfTalk)
    commentable_path = Rails.application.routes.url_helpers.polymorphic_path(comment.commentable)

    params = {
      comment:,
      receiver: comment.receiver,
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      link: "#{commentable_path}#latest-comment"
    }

    Notification.create!(
      kind: Notification.kinds['came_comment'],
      user: comment.receiver,
      sender: comment.sender,
      link: "#{commentable_path}#latest-comment",
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      read: false
    )

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:came_comment, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:came_comment, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:came_comment)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:came_comment)
    end
  end

  test '.notify(:create_article)' do
    params = {
      article: articles(:article1),
      receiver: users(:kimura)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:create_article, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:create_article, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:create_article)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:create_article)
    end
  end

  test '.notify(:added_work)' do
    params = {
      work: works(:work1),
      receiver: users(:komagata)
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.notify!(:added_work, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.notify(:added_work, **params)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify!(:added_work)
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      ActivityDelivery.with(**params).notify(:added_work)
    end
  end
end
