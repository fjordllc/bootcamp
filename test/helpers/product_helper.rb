# frozen_string_literal: true

require 'test_helper'

class ProductHelperTest < ActionView::TestCase
  test 'practice_content_for_toggle' do
    product = products(:product8)

    practice_content = practice_content_for_toggle(product, :practice)
    assert_equal 'toggle_description_body', practice_content[:id_name]
    assert_equal product.practice.description, practice_content[:description]

    practice_content = practice_content_for_toggle(product, :goal)
    assert_equal 'toggle_goal_body', practice_content[:id_name]
    assert_equal product.practice.goal, practice_content[:description]
  end
end
