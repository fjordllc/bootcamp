# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class UserCoursePracticeDecoratorTest < ActiveDecoratorTestCase
  def setup
    komagata = UserCoursePractice.new(users(:komagata))
    kensyu = UserCoursePractice.new(users(:kensyu))
    harikirio = UserCoursePractice.new(users(:harikirio))

    @user_course_practice_komagata = decorate(komagata)
    @user_course_practice_kensyu = decorate(kensyu)
    @non_required_subject_completed_user = decorate(harikirio)
  end

  test '#cached_completed_percentage' do
    practice62 = practices(:practice62)
    practice63 = practices(:practice63)
    Learning.create!(
      [{ user: users(:kensyu),
         practice: practice62,
         status: :complete },
       { user: users(:kensyu),
         practice: practice63,
         status: :complete }]
    )

    cached_completed_percentage = @user_course_practice_kensyu.cached_completed_percentage
    assert_equal cached_completed_percentage, 2.0
  end

  test '#cached_completed_fraction' do
    practice62 = practices(:practice62)
    practice63 = practices(:practice63)
    Learning.create!(
      [{ user: users(:kensyu),
         practice: practice62,
         status: :complete },
       { user: users(:kensyu),
         practice: practice63,
         status: :complete }]
    )

    cached_completed_fraction = @user_course_practice_kensyu.cached_completed_fraction
    assert_equal cached_completed_fraction, '修了: 2 （必須: 1/50）'
  end

  test '#cached_completed_fraction_in_metas' do
    fraction_in_metas = '2 （必須:1）'
    practice5 = practices(:practice5)
    practice61 = practices(:practice61)

    users(:harikirio).completed_practices = []
    Learning.create!(
      [{ user: users(:harikirio),
         practice: practice5,
         status: :complete },
       { user: users(:harikirio),
         practice: practice61,
         status: :complete }]
    )

    assert_equal fraction_in_metas, @non_required_subject_completed_user.cached_completed_fraction_in_metas
  end
end
