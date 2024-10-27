# frozen_string_literal: true

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test '#extract_practices' do
    course_practices = [practices(:practice51), practices(:practice16), practices(:practice17), practices(:practice19)]

    assert_equal 57, courses(:course1).extract_practices.count
    assert_equal course_practices, courses(:course3).extract_practices
  end
end
