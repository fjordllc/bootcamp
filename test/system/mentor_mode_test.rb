# frozen_string_literal: true

require 'application_system_test_case'

class MentorModeTest < ApplicationSystemTestCase
  test 'show/hide mentor-user-memo' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'メンター向けユーザーメモ'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert_no_text 'メンター向けユーザーメモ'
  end

  test "student don't show mentor-user-memo" do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    assert_no_text 'メンター向けユーザーメモ'
  end
end
