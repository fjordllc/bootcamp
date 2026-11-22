# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::TalkTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # 誰にどの文面で届くかは test/models/comment_test.rb で、
  # 役割ごとの未対応の件数の表示は test/integration/talk_nav_badge_test.rb で確かめる。
  test 'Receive a notification when someone except myself comments on my talk room' do
    talk_id = users(:kimura).talk.id
    visit_with_auth "/talks/#{talk_id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'

    assert_user_has_notification(user: users(:kimura), kind: Notification.kinds[:came_comment], text: '相談部屋でkomagataさんからコメントがありました。')
  end

  test 'The number of action uncompleted comments is displayed in the global navigation and action uncompleted tab of the talks room' do
    visit_with_auth '/talks/action_uncompleted', 'komagata'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/action_uncompleted']") do
        assert_selector '.global-nav__item-count.a-notification-count.is-only-mentor', count: 1
      end
    end
    assert_selector '.page-tabs__item-count.a-notification-count', count: 1

    talk_id = users(:with_hyphen).talk.id
    visit_with_auth "/talks/#{talk_id}", 'komagata'
    find('.check-button').click
    assert_text '対応済みにしました'

    visit '/talks/action_uncompleted'
    assert_text '未対応の相談部屋はありません'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/action_uncompleted']") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
    assert_no_selector '.page-tabs__item-count.a-notification-count'
  end
end
