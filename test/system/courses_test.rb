# frozen_string_literal: true

require 'application_system_test_case'

class CoursesTest < ApplicationSystemTestCase
  test 'cant see unpublished courses' do
    visit_with_auth '/courses', 'hajime'
    assert_no_link courses(:course2).title
    assert_no_text courses(:course2).description
  end
end
