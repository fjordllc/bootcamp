# frozen_string_literal: true

require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test 'all_countries_with_subdivisions' do
    countries = JSON.parse(all_countries_with_subdivisions)
    assert_includes countries['JP'], %w[北海道 01]
    assert_includes countries['US'], %w[アラスカ州 AK]
  end

  test '#roles_for_select' do
    user_roles = [
      %w[全員 all],
      %w[現役生 student_and_trainee],
      %w[非アクティブ inactive],
      %w[休会 hibernated],
      %w[退会 retired],
      %w[卒業 graduate],
      %w[アドバイザー adviser],
      %w[メンター mentor],
      %w[研修生 trainee],
      %w[忘年会 year_end_party],
      %w[お試し延長 campaign]
    ]
    assert roles_for_select, user_roles
  end

  test '#jobs_for_select' do
    user_jobs = [
      %w[全員 all],
      %w[学生 student],
      %w[会社員 office_worker],
      %w[フリーター part_time_worker],
      %w[休職中 vacation],
      %w[働いていない unemployed]
    ]
    assert jobs_for_select, user_jobs
  end

  test '#user_icon_frame_class_for_new_user' do
    new_user = users(:otameshi)
    standard_user = users(:kimura)

    def new_user.primary_role = 'student'
    def new_user.joining_status = 'new-user'

    def standard_user.primary_role = 'student'
    def standard_user.joining_status = ''

    assert_equal 'a-user-role is-student is-new-user', user_icon_frame_class(new_user)
    assert_equal 'a-user-role is-student', user_icon_frame_class(standard_user)
  end
end
