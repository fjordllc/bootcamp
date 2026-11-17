# frozen_string_literal: true

require 'browserless_system_test_case'

class Mentor::CodingTestsBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing coding_tests' do
    visit_with_auth '/mentor/coding_tests', 'mentormentaro'
    assert_equal 'コーディングテスト | FBC', title
  end
end
