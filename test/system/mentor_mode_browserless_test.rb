# frozen_string_literal: true

require 'browserless_system_test_case'

class MentorModeBrowserlessTest < BrowserlessSystemTestCase
  test "student don't show mentor-user-memo" do
    visit_with_auth user_path(users(:hatsuno)), 'kimura'
    assert_no_text 'ユーザーメモ'
  end
end
