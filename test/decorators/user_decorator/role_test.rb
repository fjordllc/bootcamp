# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

module UserDecorator
  class RoleTest < ActiveDecoratorTestCase
    test '#staff_roles' do
      admin_mentor = decorate(users(:komagata))
      student = decorate(users(:hajime))

      assert_equal '管理者、メンター', admin_mentor.staff_roles
      assert_equal '', student.staff_roles
    end

    test '#roles_to_s' do
      admin_mentor = decorate(users(:komagata))
      student = decorate(users(:hajime))
      graduated = decorate(users(:sotugyou))
      admin = decorate(users(:adminonly))
      adviser = decorate(users(:advijirou))
      mentor = decorate(users(:mentormentaro))
      trainee = decorate(users(:kensyu))
      retired = decorate(users(:taikai))
      hibernationed = decorate(users(:kyuukai))

      assert_equal '管理者、メンター', admin_mentor.roles_to_s
      assert_equal '', student.roles_to_s
      assert_equal '卒業生', graduated.roles_to_s
      assert_equal '管理者', admin.roles_to_s
      assert_equal 'アドバイザー', adviser.roles_to_s
      assert_equal 'メンター', mentor.roles_to_s
      assert_equal '研修生', trainee.roles_to_s
      assert_equal '退会ユーザー', retired.roles_to_s
      assert_equal '休会ユーザー', hibernationed.roles_to_s
    end
  end
end
