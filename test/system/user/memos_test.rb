# frozen_string_literal: true

require 'application_system_test_case'

class User::MemoTest < ApplicationSystemTestCase
  test 'update memorandom' do
    login_user 'komagata', 'testtest'
    visit user_path(users(:hatsuno))
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: 'ユーザーメンターメモ'
    click_button '保存する'
    wait_for_vuejs
    assert_text 'ユーザーメンターメモ'
    visit user_path(users(:hatsuno))
    assert_text 'ユーザーメンターメモ'
  end

  test 'do not update memorandom when cancel' do
    login_user 'komagata', 'testtest'
    visit user_path(users(:kimura))
    assert_text 'kimuraさんのメモ'
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: 'ユーザーメンターメモ'
    click_button 'キャンセル'
    wait_for_vuejs
    assert_no_text 'ユーザーメンターメモ'
    assert_text 'kimuraさんのメモ'
    visit user_path(users(:kimura))
    assert_no_text 'ユーザーメンターメモ'
    assert_text 'kimuraさんのメモ'
  end

  test 'admin can see memorandom' do
    login_user 'komagata', 'testtest'
    visit user_path(users(:hatsuno))
    assert_text 'メンター向けユーザーメモ'
  end

  test 'mentor can see memorandom' do
    login_user 'yamada', 'testtest'
    visit user_path(users(:hatsuno))
    assert_text 'メンター向けユーザーメモ'
  end

  test 'adviser can’t see memorandom' do
    login_user 'advijirou', 'testtest'
    visit user_path(users(:hatsuno))
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'trainee can’t see memorandom' do
    login_user 'kensyu', 'testtest'
    visit user_path(users(:hatsuno))
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'graduate can’t see memorandom' do
    login_user 'sotugyou', 'testtest'
    visit user_path(users(:hatsuno))
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'student can’t see memorandom' do
    login_user 'hatsuno', 'testtest'
    visit user_path(users(:hatsuno))
    assert_no_text 'メンター向けユーザーメモ'
  end
end
