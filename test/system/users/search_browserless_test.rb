# frozen_string_literal: true

require 'browserless_system_test_case'

class Users::SearchBrowserlessTest < BrowserlessSystemTestCase
  test "don't show incremental search when target's users aren't exist" do
    user = users(:jobseeking)
    user.update!(career_path: 0)

    visit_with_auth '/users?target=job_seeking', 'komagata'
    assert_no_selector '.users-item'
    assert has_no_field? 'js-user-search-input'

    user.update!(career_path: 1)
  end
end
