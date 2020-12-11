# frozen_string_literal: true

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test '.category' do
    practice = practices(:practice1)
    course = courses(:course1)
    category = categories(:category2)

    assert_equal category, Category.category(practice: practice, course: course)
  end
end
