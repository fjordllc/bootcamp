# frozen_string_literal: true

require 'browserless_system_test_case'

class Admin::GrantCourseApplicationsTest < BrowserlessSystemTestCase
  test 'show listing grant_course_applications' do
    visit_with_auth '/admin/grant_course_applications', 'komagata'
    assert_title '給付金対応コース受講申請 | FBC'
  end
end
