# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::ArticlesTest < NotificationSystemTestCase
  setup do
    @article = articles(:article1)
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_kind = Notification.kinds[:create_article]
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # 通知の対象ごとの届き先と、WIP・更新で通知しないことは
  # test/integration/article_notifications_test.rb で確かめる。
  test 'the notification is sent only when the article is first published' do
    visit_with_auth new_article_path, 'komagata'
    fill_in('article_title', with: '通知テスト1回目')
    fill_in('article_body', with: 'test')
    page.accept_confirm do
      click_on '公開する'
    end
    assert_text '記事を作成しました'

    assert_user_has_notification(user: users(:hajime), kind: @notice_kind, text: 'komagataさんがブログに「通知テスト1回目」を投稿しました。', unread: true)

    # Mark notifications as read
    hajime = users(:hajime)
    hajime_notifications = Notification.where(user: hajime, kind: @notice_kind, read: false)
    hajime_notifications.each { |n| n.update!(read: true) }

    visit_with_auth edit_article_path(@article), 'komagata'
    fill_in('article_title', with: '通知テスト2回目')
    click_on '更新する'

    hajime_unread_notifications = Notification.where(user: hajime, kind: @notice_kind, read: false)
    assert_empty hajime_unread_notifications
    assert_user_has_no_notification(user: hajime, kind: @notice_kind, text: 'komagataさんがブログに「通知テスト2回目」を投稿しました。')
  end
end
