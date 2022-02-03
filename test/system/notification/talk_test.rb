# frozen_string_literal: true

require 'application_system_test_case'

class Notification::TalkTest < ApplicationSystemTestCase
  test 'Admin receive a notification when someone comments on a talk room' do
    talk_id = users(:kimura).talk.id
    visit_with_auth "/talks/#{talk_id}", 'kimura'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'

    visit_with_auth '/notifications', 'machida'

    within first('.thread-list-item.is-unread') do
      assert_text 'kimuraさんからコメントが届きました。'
    end
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
    wait_for_vuejs
    assert_text 'test'

    visit '/notifications'

    within first('.thread-list-item.is-unread') do
      assert_no_text 'komagataさんからコメントが届きました。'
    end

    visit_with_auth '/notifications', 'machida'

    within first('.thread-list-item.is-unread') do
      assert_text 'komagataさんからコメントが届きました。'
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
    wait_for_vuejs
    assert_text 'test'

    visit_with_auth '/notifications', 'kimura'

    within first('.thread-list-item.is-unread') do
      assert_text 'komagataさんからコメントが届きました。'
    end
  end
end
