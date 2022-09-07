# frozen_string_literal: true

require 'application_system_test_case'

class Notification::TalkTest < ApplicationSystemTestCase
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

    visit_with_auth '/notifications', 'machida'

    within first('.card-list-item.is-unread') do
      click_link 'kimuraさんの相談部屋でkimuraさんからコメントが届きました。'
    end

    assert_current_path(/#latest-comment$/, url: true)
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

    visit '/notifications'
    assert_selector '.page-header__title', text: '通知'

    within first('.card-list-item.is-unread') do
      assert_no_text 'kimuraさんの相談部屋でkomagataさんからコメントが届きました。'
    end

    visit_with_auth '/notifications', 'machida'

    within first('.card-list-item.is-unread') do
      assert_text 'kimuraさんの相談部屋でkomagataさんからコメントが届きました。'
    end
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

    visit_with_auth '/notifications', 'kimura'

    within first('.card-list-item.is-unread') do
      click_link '相談部屋でkomagataさんからコメントがありました。'
    end

    assert_current_path(/#latest-comment$/, url: true)
  end

  test 'The number of unreplied comments is displayed in the global navigation and unreplied tab of the talks room' do
    visit_with_auth '/talks/unreplied', 'komagata'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/unreplied']") do
        assert_selector '.global-nav__item-count.a-notification-count.is-only-mentor', count: 1
      end
    end
    assert_selector '.page-tabs__item-count.a-notification-count', count: 1

    talk_id = users(:with_hyphen).talk.id
    visit_with_auth "/talks/#{talk_id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    assert_text 'コメントを投稿しました'

    visit '/talks/unreplied'
    assert_text '未返信の相談部屋はありません'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/unreplied'") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
    assert_no_selector '.page-tabs__item-count.a-notification-count'
  end

  test 'The number of unreplied comments is not displayed in the global navigation when mentor visit page' do
    user = users(:mentormentaro)
    visit_with_auth root_path, 'mentormentaro'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/#{user.talk.id}#latest-comment'") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
  end

  test 'The number of unreplied comments is not displayed in the global navigation when advisor visit page' do
    user = users(:advijirou)
    visit_with_auth root_path, 'advijirou'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    within(:css, '.global-nav') do
      within(:css, "a[href='/talks/#{user.talk.id}#latest-comment'") do
        assert_no_selector '.global-nav__item-count.a-notification-count.is-only-mentor'
      end
    end
  end

  test 'The number of unreplied comments is not displayed in the global navigation when student visit page' do
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
