# frozen_string_literal: true

require 'application_system_test_case'

class Notification::CommentsTest < ApplicationSystemTestCase
  test 'recieve only one notificaiton if you send two mentions in one comment' do
    login_user 'komagata', 'testtest'
    visit "/reports/#{reports(:report1).id}"

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: '@machida @machida test')
    end
    click_button 'コメントする'
    wait_for_vuejs
    assert_text '@machida @machida test'

    logout
    login_user 'machida', 'testtest'

    open_notification
    assert_equal 'komagataさんからメンションがきました。',
                 notification_message
    assert_selector '.header-notification-count', text: '1'
  end
end
