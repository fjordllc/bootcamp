# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class ProductDecoratorTest < ActiveDecoratorTestCase
  setup do
    @product = decorate(products(:product8))
  end

  test '#meta_description' do
    assert_equal(
      'kimura (キムラ タダシ)さんが提出した、プラクティス「PC性能の見方を知る」の提出物です。',
      @product.meta_description
    )
  end

  test '#after_submission_message?' do
    assert @product.after_submission_message?(users(:kimura))
    assert_not @product.after_submission_message?(users(:komagata))
  end

  test '#user_course_practice' do
    assert_instance_of UserCoursePractice, @product.user_course_practice
    assert_equal users(:kimura), @product.user_course_practice.user
  end
end
