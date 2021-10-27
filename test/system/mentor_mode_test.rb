# frozen_string_literal: true

require 'application_system_test_case'

class MentorModeTest < ApplicationSystemTestCase
  test 'show/hide mentor-user-memo to the user_profile' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'メンター向けユーザーメモ'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'show/hide mentor-user-memo to the report' do
    visit_with_auth report_path(reports(:report10)), 'komagata'
    assert_text 'メンター向けユーザーメモ'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'show/hide retire_reason' do
    visit_with_auth user_path(users(:yameo)), 'komagata'
    assert_text '内容が難しかった'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert_no_text '内容が難しかった'
  end

  test "student don't show mentor-user-memo" do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    assert_no_text 'メンター向けユーザーメモ'
  end
end
