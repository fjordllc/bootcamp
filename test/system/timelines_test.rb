# frozen_string_literal: true

require 'application_system_test_case'

class TimelinesTest < ApplicationSystemTestCase
  test 'displays timeline context in user context after login' do
    visit_with_auth "/users/#{users(:kimura).id}/timelines/", 'kimura'
    assert_text '今日は調子が良かった'
  end

  test 'create timeline' do
    visit_with_auth "/users/#{users(:kimura).id}/timelines/", 'kimura'
    within 'form[name=timeline]' do
      fill_in 'context', with: '今日は素晴らしい一日でした！'
      click_on '投稿'
    end
    assert_text '今日は素晴らしい一日でした！'
    assert_text 'ツイートを送信しました。'
  end

  test 'not create timeline with empty context' do
    visit_with_auth "/users/#{users(:kimura).id}/timelines/", 'kimura'
    within 'form[name=timeline]' do
      fill_in 'context', with: ''
      click_on '投稿'
    end
    assert_text 'ツイートに失敗しました。'
  end

  test 'not post button display other users' do
    visit_with_auth "/users/#{users(:kimura).id}/timelines/", 'hatsuno'
    assert_no_text '投稿'
  end
end
