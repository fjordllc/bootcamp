# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::CommentsTest < NotificationSystemTestCase
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

    assert_user_has_notification(user: users(:machida), kind: Notification.kinds[:mentioned], text: 'komagataさんの日報「作業週1日目」へのコメントでkomagataさんからメンションがきました。')
    assert_equal 1, notifications.count
  end
end
