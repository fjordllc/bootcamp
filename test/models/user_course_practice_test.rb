# frozen_string_literal: true

require 'test_helper'

class UserCoursePracticeTest < ActiveSupport::TestCase
  setup do
    @user_course_practice = UserCoursePractice.new(users(:kensyu))
  end

  test '#categories_with_uniq_practices' do
    user = users(:kensyu)
    categories_with_uniq_practices = @user_course_practice.categories_with_uniq_practices
    category_with_uniq_practices = categories_with_uniq_practices.select { |category| category.name == 'Ruby on Rails(Rails 6.1版)' }.first
    assert_equal 0, category_with_uniq_practices.practices.size

    category = user.course.categories.where(name: 'Ruby on Rails(Rails 6.1版)').first
    assert_not_equal 0, category.practices.size
  end

  test '#uniq_practice_ids' do
    uniq_practices_ids = @user_course_practice.uniq_practice_ids

    assert_equal uniq_practices_ids.size, uniq_practices_ids.uniq.size
  end

  test '#filter_category_by_practice_ids' do
    category = categories(:category4)
    practice_ids = category.practice_ids[0..3] << 0
    filterd_category, left_ids = @user_course_practice.filter_category_by_practice_ids(category, practice_ids)

    assert_equal filterd_category.practices.size, 4
    assert_equal left_ids, [0]
  end

  test '#sorted_practices' do
    user = users(:kensyu)
    practices = user.course.practices.reverse
    orderd_practices = @user_course_practice.sorted_practices
    assert_equal orderd_practices.last.id, practices.first.id
  end

  test '#skipped_practice_ids' do
    assert_includes(@user_course_practice.skipped_practice_ids, practices(:practice8).id)
  end
end
