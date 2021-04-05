# frozen_string_literal: true

require 'application_system_test_case'

class Admin::MentorModeTest < ApplicationSystemTestCase
  test 'admin show/hide mentor-user-memo' do
    login_user 'komagata', 'testtest'
    visit user_path(users(:hatsuno))
    assert page.has_content? 'メンター向けユーザーメモ'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert page.has_no_content? 'メンター向けユーザーメモ'
  end

  test 'student don`t show mentor-user-memo' do
    login_user 'kimura', 'testtest'
    assert page.has_no_content? 'メンター向けユーザーメモ'
  end
end
