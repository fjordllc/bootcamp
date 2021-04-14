# frozen_string_literal: true

require 'application_system_test_case'

class Admin::MentorModeTest < ApplicationSystemTestCase
  test 'admin show/hide mentor-user-memo' do
    login_user 'komagata', 'testtest'
    visit user_path(users(:hatsuno))
    page.assert_text('メンター向けユーザーメモ')
    find(:css, '#checkbox-mentor-mode').set(false)
    page.assert_no_text('メンター向けユーザーメモ')
  end

  test 'student do not show mentor-user-memo' do
    login_user 'kimura', 'testtest'
    page.assert_no_text('メンター向けユーザーメモ')
  end
end
