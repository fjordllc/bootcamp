# frozen_string_literal: true

require 'browserless_system_test_case'

class CoursesBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing courses' do
    visit_with_auth '/courses', 'mentormentaro'
    assert_equal 'コース一覧 | FBC', title
  end

  test 'show published courses' do
    visit_with_auth '/courses', 'hajime'
    assert_link courses(:course1).title
    assert_text courses(:course1).description
  end
end
