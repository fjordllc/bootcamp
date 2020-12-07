# frozen_string_literal: true

require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test ".category" do
    practice = practices(:practice_1)
    course = courses(:course_1)
    category = categories(:category_2)

    assert_equal category, Category.category(practice: practice, course: course)
  end
end
