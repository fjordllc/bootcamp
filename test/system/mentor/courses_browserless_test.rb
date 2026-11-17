# frozen_string_literal: true

require 'browserless_system_test_case'

class Mentor::CoursesBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing courses' do
    visit_with_auth '/mentor/courses', 'mentormentaro'
    assert_equal 'メンターページ | FBC', title
  end

  test 'can see closed courses' do
    visit_with_auth '/courses', 'mentormentaro'
    assert_text courses(:course2).title
    assert_text courses(:course2).description
  end
end
