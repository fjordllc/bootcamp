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

  test 'Admin receive a notification when someone comments on a talk room' do
    talk_id = users(:kimura).talk.id
    visit_with_auth "/talks/#{talk_id}", 'kimura'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'

    assert_user_has_notification(user: users(:machida), kind: Notification.kinds[:came_comment], text: 'kimuraさんの相談部屋でkimuraさんからコメントが届きました。')
  end

  test 'Admin except myself receive a notification when other admin comments on a talk room' do
    talk_id = users(:kimura).talk.id
    visit_with_auth "/talks/#{talk_id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:came_comment], text: 'kimuraさんの相談部屋でkomagataさんからコメントが届きました。')
    assert_user_has_notification(user: users(:machida), kind: Notification.kinds[:came_comment], text: 'kimuraさんの相談部屋でkomagataさんからコメントが届きました。')
  end

  test 'Receive a notification when someone except myself comments on my talk room' do
    talk_id = users(:kimura).talk.id
    visit_with_auth "/talks/#{talk_id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
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
      within(:css, "a[href='/talks/action_uncompleted'") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
    assert_no_selector '.page-tabs__item-count.a-notification-count'
  end

  test 'The number of action uncompleted comments is not displayed in the global navigation when mentor visit page' do
    user = users(:mentormentaro)
    visit_with_auth root_path, 'mentormentaro'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/#{user.talk.id}#latest-comment'") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
  end

  test 'The number of action uncompleted comments is not displayed in the global navigation when advisor visit page' do
    user = users(:advijirou)
    visit_with_auth root_path, 'advijirou'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/#{user.talk.id}#latest-comment'") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
  end

  test 'The number of action uncompleted comments is not displayed in the global navigation when student visit page' do
    user = users(:kimura)
    visit_with_auth root_path, 'kimura'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/#{user.talk.id}#latest-comment'") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
  end
end
