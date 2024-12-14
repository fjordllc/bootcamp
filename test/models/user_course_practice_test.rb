# frozen_string_literal: true

require 'test_helper'
require 'supports/product_helper'

class UserCoursePracticeTest < ActiveSupport::TestCase
  include ProductHelper
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

  test '#sorted_practices' do
    user = users(:kensyu)
    practices = user.course.practices.reverse
    orderd_practices = @user_course_practice_kensyu.sorted_practices
    assert_equal orderd_practices.last.id, practices.first.id
  end

  test '#skipped_practice_ids' do
    assert_includes(@user_course_practice_kensyu.skipped_practice_ids, practices(:practice8).id)
  end

  test 'get category active or unstarted practice' do
    komagata = @user_course_practice_komagata
    assert_equal 917_504_053, komagata.category_active_or_unstarted_practice.id
    machida = @user_course_practice_machida
    practice1 = practices(:practice1)
    user = users(:machida)
    create_checked_product(user, practices(:practice1))
    Learning.create!(
      user: users(:machida),
      practice: practice1,
      status: :complete
    )
    assert_equal 685_020_562, machida.category_active_or_unstarted_practice.id
  end

  test '#required_practices' do
    not_required_practice = practices(:practice62)
    required_practice = practices(:practice63)
    required_practices = @user_course_practice_kimura.required_practices

    assert_includes required_practices, required_practice
    assert_not_includes required_practices, not_required_practice
    assert_equal required_practices.size, required_practices.uniq.size
  end

  test '#completed_practices' do
    practice62 = practices(:practice62)
    practice63 = practices(:practice63)
    user = users(:komagata)
    create_checked_product(user, practices(:practice62))
    create_checked_product(user, practices(:practice63))
    Learning.create!(
      [{ user: users(:kensyu),
         practice: practice62,
         status: :complete },
       { user: users(:kensyu),
         practice: practice63,
         status: :complete }]
    )

    completed_practices = @user_course_practice_kensyu.completed_practices
    assert_includes completed_practices, practices(:practice62)
    assert_includes completed_practices, practices(:practice63)
    assert_equal completed_practices.size, completed_practices.uniq.size
  end

  test '#completed_required_practices' do
    practice62 = practices(:practice62)
    practice63 = practices(:practice63)
    user = users(:komagata)
    create_checked_product(user, practices(:practice62))
    create_checked_product(user, practices(:practice63))
    Learning.create!(
      [{ user: users(:kensyu),
         practice: practice62,
         status: :complete },
       { user: users(:kensyu),
         practice: practice63,
         status: :complete }]
    )

    completed_required_practices = @user_course_practice_kensyu.completed_required_practices
    assert_not_includes completed_required_practices, practices(:practice62)
    assert_includes completed_required_practices, practices(:practice63)
    assert_equal completed_required_practices.size, completed_required_practices.uniq.size
  end

  test '#completed_percentage' do
    practice62 = practices(:practice62)
    practice63 = practices(:practice63)
    user = users(:komagata)
    create_checked_product(user, practices(:practice62))
    create_checked_product(user, practices(:practice63))
    Learning.create!(
      [{ user: users(:kensyu),
         practice: practice62,
         status: :complete },
       { user: users(:kensyu),
         practice: practice63,
         status: :complete }]
    )

    completed_percentage = @user_course_practice_kensyu.completed_percentage
    assert_equal completed_percentage, 2.0
  end

  test '#completed_practices_size_by_category' do
    category2 = categories(:category2)
    assert_equal 1, @user_course_practice_kimura.completed_practices_size_by_category[category2.id]
  end
end
