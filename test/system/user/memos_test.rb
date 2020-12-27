# frozen_string_literal: true

require 'application_system_test_case'

class User::MemoTest < ApplicationSystemTestCase
  setup do
    login_user 'komagata', 'testtest'
    @user = users(:hatsuno)
  end

  test 'update memorandom without page transition' do
    visit user_path(@user)
    wait_for_vuejs
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: 'ユーザーメンターメモ'
    click_button '保存する'
    wait_for_vuejs
    assert_text 'ユーザーメンターメモ'
  end
end
