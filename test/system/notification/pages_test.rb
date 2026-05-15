# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::PagesTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'Only admins and mentors are notified' do
    visit_with_auth '/pages', 'komagata'
    click_link 'Docs作成'

    within('.form') do
      fill_in('page[title]', with: 'DocsTest')
      fill_in('page[body]', with: 'DocsTestBody')
    end
    click_button 'Docを公開'
    assert_text 'ドキュメントを作成しました。'

    assert_user_has_notification(user: users(:mentormentaro), kind: Notification.kinds[:create_pages], text: 'komagataさんがDocsにDocsTestを投稿しました。')
    assert_user_has_notification(user: users(:machida), kind: Notification.kinds[:create_pages], text: 'komagataさんがDocsにDocsTestを投稿しました。')
    assert_user_has_no_notification(user: users(:hatsuno), kind: Notification.kinds[:create_pages], text: 'komagataさんがDocsにDocsTestを投稿しました。')
    assert_user_has_no_notification(user: users(:yameo), kind: Notification.kinds[:create_pages], text: 'komagataさんがDocsにDocsTestを投稿しました。')
  end

  test "don't notify when page is WIP" do
    visit_with_auth '/pages', 'komagata'
    click_link 'Docs作成'

    within('.form') do
      fill_in('page[title]', with: 'DocsTest')
      fill_in('page[body]', with: 'DocsTestBody')
    end
    click_button 'WIP'
    assert_text 'ドキュメントをWIPとして保存しました。'

    assert_user_has_no_notification(user: users(:hatsuno), kind: Notification.kinds[:create_pages], text: 'komagataさんがDocsにDocsTestを投稿しました。')
  end

  test 'Notify Docs updated from WIP' do
    page = pages(:page5)
    visit_with_auth page_path(page), 'komagata'

    click_link '内容変更'
    click_button 'Docを公開'
    assert_text 'ドキュメントを作成しました。'

    assert_user_has_notification(user: users(:machida), kind: Notification.kinds[:create_pages], text: 'komagataさんがDocsにWIPのテストを投稿しました。')
  end
end
