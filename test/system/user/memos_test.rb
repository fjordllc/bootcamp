# frozen_string_literal: true

require 'application_system_test_case'

class User::MemoTest < ApplicationSystemTestCase
  test 'update memorandom without page transition' do
    login_user 'komagata', 'testtest'
    visit user_path(users(:hatsuno))
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: 'ユーザーメンターメモ'
    click_button '保存する'
    wait_for_vuejs
    assert_text 'ユーザーメンターメモ'
  end

  test 'No one but mentor or administrator can see memorandom' do
    login_user 'hatsuno', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_no_content? 'メンター向けメモ'
  end
end
