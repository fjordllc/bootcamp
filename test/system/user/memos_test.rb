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

  test 'admin can see memorandom' do
    login_user 'komagata', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_content? 'メンター向けメモ'
  end

  test 'mentor can see memorandom' do
    login_user 'yamada', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_content? 'メンター向けメモ'
  end

  test 'adviser can’t see memorandom' do
    login_user 'advijirou', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_no_content? 'メンター向けメモ'
  end

  test 'trainee can’t see memorandom' do
    login_user 'kensyu', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_no_content? 'メンター向けメモ'
  end

  test 'graduate can’t see memorandom' do
    login_user 'sotugyou', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_no_content? 'メンター向けメモ'
  end

  test 'student can’t see memorandom' do
    login_user 'hatsuno', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_no_content? 'メンター向けメモ'
  end
end
