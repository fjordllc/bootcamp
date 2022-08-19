# frozen_string_literal: true

require 'application_system_test_case'

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
end
