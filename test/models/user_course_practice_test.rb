# frozen_string_literal: true

require 'test_helper'

class UserCoursePracticeTest < ActiveSupport::TestCase
  setup do
    @user_course_practice_kensyu = UserCoursePractice.new(users(:kensyu))
    @user_course_practice_kimura = UserCoursePractice.new(users(:kimura))
    @user_course_practice_komagata = UserCoursePractice.new(users(:komagata))
    @user_course_practice_machida = UserCoursePractice.new(users(:machida))
  end

  test '#categories_for_skip_practices' do
    user = users(:kensyu)
    categories = @user_course_practice_kensyu.categories_for_skip_practice
    category_for_skip_practice = categories.select { |category| category.name == 'Ruby on Rails(Rails 6.1版)' }.first
    assert_equal 0, category_for_skip_practice.practices.size

    category = user.course.categories.where(name: 'Ruby on Rails(Rails 6.1版)').first
    assert_not_equal 0, category.practices.size
  end

  test '#uniq_practice_ids' do
    uniq_practices_ids = @user_course_practice_kensyu.uniq_practice_ids

    assert_equal uniq_practices_ids.size, uniq_practices_ids.uniq.size
  end

  test '#filter_category_by_practice_ids' do
    category = categories(:category4)
    practice_ids = category.practice_ids[0..3] << 0
    filterd_category, left_ids = @user_course_practice_kensyu.filter_category_by_practice_ids(category, practice_ids)

    assert_equal filterd_category.practices.size, 4
    assert_equal left_ids, [0]
  end

  test '#sorted_practices' do
    user = users(:kensyu)
    practices = user.course.practices.reverse
    orderd_practices = @user_course_practice_kensyu.sorted_practices
    assert_equal orderd_practices.last.id, practices.first.id
  end

  test '#skipped_practice_ids' do
    assert_includes(@user_course_practice_kensyu.skipped_practice_ids, practices(:practice8).id)
  end

  test '#completed_practices_size_by_category' do
    category2 = categories(:category2)
    assert_equal 1, @user_course_practice_kimura.completed_practices_size_by_category[category2.id]
  end

  test 'get category active or unstarted practice' do
    komagata = @user_course_practice_komagata
    assert_equal 917_504_053, komagata.category_active_or_unstarted_practice.id
    machida = @user_course_practice_machida
    practice1 = practices(:practice1)
    Learning.create!(
      user: users(:machida),
      practice: practice1,
      status: :complete
    )
    assert_equal 685_020_562, machida.category_active_or_unstarted_practice.id
  end
end
