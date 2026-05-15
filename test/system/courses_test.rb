# frozen_string_literal: true

require 'application_system_test_case'

class CoursesTest < ApplicationSystemTestCase
  test 'show listing courses' do
    visit_with_auth '/courses', 'mentormentaro'
    assert_equal 'コース一覧 | FBC', title
  end

  test 'show published courses' do
    visit_with_auth '/courses', 'hajime'
    assert_link courses(:course1).title
    assert_text courses(:course1).description
  end

  test 'cant see unpublished courses' do
    visit_with_auth '/courses', 'hajime'
    assert_no_link courses(:course2).title
    assert_no_text courses(:course2).description
  end
end
