# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class ProductDecoratorTest < ActiveDecoratorTestCase
  test 'practice_content_for_toggle' do
    product = ActiveDecorator::Decorator.instance.decorate(products(:product8))

    practice_content = product.practice_content_for_toggle(:practice)
    assert_equal 'toggle_description_body', practice_content[:id_name]
    assert_equal product.practice.description, practice_content[:description]

    practice_content = product.practice_content_for_toggle(:goal)
    assert_equal 'toggle_goal_body', practice_content[:id_name]
    assert_equal product.practice.goal, practice_content[:description]
  end
end
