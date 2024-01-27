# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/notification_helper'

class Notification::CommentsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'recieve only one notificaiton if you send two mentions in one comment' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: '@machida @machida test')
    end
    click_button 'コメントする'
    assert_text '@machida @machida test'

    visit_with_auth '/notifications', 'machida'

    within first('.card-list-item.is-unread') do
      assert_text 'komagataさんの日報「作業週1日目」へのコメントでkomagataさんからメンションがきました。'
    end
    assert_selector '.header-notification-count', text: '1'
  end

  test 'Users mentioned in comments on the Report page are notified' do
    post_mention = lambda { |comment|
      visit report_path(reports(:report1).id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    title = "#{reports(:report1).commentable_notification_title}へのコメントでkimuraさんからメンションがきました。"
    assert_commentable_notification(title, 'kimura', 'hatsuno', post_mention)
  end

  test 'Users mentioned in comments on the product page are notified' do
    post_mention = lambda { |comment|
      visit product_path(products(:product1).id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    title = "#{products(:product1).commentable_notification_title}へのコメントでkimuraさんからメンションがきました。"
    assert_commentable_notification(title, 'kimura', 'hatsuno', post_mention)
  end

  test 'Users mentioned in comments on the Event page are notified' do
    post_mention = lambda { |comment|
      visit event_path(events(:event1).id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    title = "#{events(:event1).commentable_notification_title}へのコメントでkimuraさんからメンションがきました。"
    assert_commentable_notification(title, 'kimura', 'hatsuno', post_mention)
  end

  test 'Users mentioned in comments on the Docs page are notified' do
    post_mention = lambda { |comment|
      visit page_path(pages(:page1).id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    title = "#{pages(:page1).commentable_notification_title}へのコメントでkimuraさんからメンションがきました。"
    assert_commentable_notification(title, 'kimura', 'hatsuno', post_mention)
  end

  test 'Users mentioned in comments on the Announcement page are notified' do
    post_mention = lambda { |comment|
      visit announcement_path(announcements(:announcement1).id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    title = "#{announcements(:announcement1).commentable_notification_title}へのコメントでkimuraさんからメンションがきました。"
    assert_commentable_notification(title, 'kimura', 'hatsuno', post_mention)
  end

  test 'Users mentioned in comments on the Regular event page are notified' do
    post_mention = lambda { |comment|
      visit regular_event_path(regular_events(:regular_event1).id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    title = "#{regular_events(:regular_event1).commentable_notification_title}へのコメントでkimuraさんからメンションがきました。"
    assert_commentable_notification(title, 'kimura', 'hatsuno', post_mention)
  end

  test 'Users mentioned in comments on the Talk page are NOT notified' do
    user = users(:kimura)
    post_mention = lambda { |comment|
      visit talk_path(user.talk.id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    login_user 'kimura', 'testtest'
    post_mention.call('@hatsuno にメンション通知がいくかのテスト')
    logout
    login_user 'hatsuno', 'testtest'

    assert_not exists_unread_notification?('kimuraさんからメンションがきました。')
  end
end

def assert_commentable_notification(
  title, writer_login_name, mention_target_login_name, post_mention
)
  login_user writer_login_name, 'testtest'
  post_mention.call("@#{mention_target_login_name} にメンション通知がいくかのテスト")
  logout
  login_user mention_target_login_name, 'testtest'
  assert exists_unread_notification?(title)
end
