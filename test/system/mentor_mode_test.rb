# frozen_string_literal: true

require 'application_system_test_case'

class MentorModeTest < ApplicationSystemTestCase
  test 'show/hide mentor-user-memo to the user_profile' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'ユーザーメモ'
    page.execute_script("document.querySelector('#checkbox-mentor-mode').click()")
    assert_no_text 'ユーザーメモ'
  end

  test 'show/hide mentor-user-memo to the report' do
    visit_with_auth report_path(reports(:report10)), 'komagata'
    assert_text 'ユーザーメモ'
    page.execute_script("document.querySelector('#checkbox-mentor-mode').click()")
    assert_no_text 'ユーザーメモ'
  end

  test 'show/hide retire_reason' do
    visit_with_auth user_path(users(:yameo)), 'komagata'
    assert_text '内容が難しかった'
    page.execute_script("document.querySelector('#checkbox-mentor-mode').click()")
    assert_no_text '内容が難しかった'
  end

  test "student don't show mentor-user-memo" do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    assert_no_text 'ユーザーメモ'
  end
end
