# frozen_string_literal: true

require 'application_system_test_case'

class Admin::GrantCourseApplicationsTest < ApplicationSystemTestCase
  test 'show listing grant_course_applications' do
    visit_with_auth '/admin/grant_course_applications', 'komagata'
    assert_title '給付金対応コース申し込み | FBC'
  end
end
