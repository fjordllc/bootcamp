# frozen_string_literal: true

require 'test_helper'

class UserDecoratorTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  def setup
    ActiveDecorator::ViewContext.push(controller.view_context)
    @admin_mentor_user = ActiveDecorator::Decorator.instance.decorate(users(:komagata))
    @student_user = ActiveDecorator::Decorator.instance.decorate(users(:hajime))
    @graduated_user = ActiveDecorator::Decorator.instance.decorate(users(:sotugyou))
    @admin_user = ActiveDecorator::Decorator.instance.decorate(users(:adminonly))
    @adviser_user = ActiveDecorator::Decorator.instance.decorate(users(:advijirou))
    @mentor_user = ActiveDecorator::Decorator.instance.decorate(users(:mentormentaro))
    @trainee_user = ActiveDecorator::Decorator.instance.decorate(users(:kensyu))
    @retired_user = ActiveDecorator::Decorator.instance.decorate(users(:taikai))
  end

  test '#staff_roles' do
    assert_equal '管理者、メンター', @admin_mentor_user.staff_roles
    assert_equal '', @student_user.staff_roles
  end

  test '#icon_title' do
    assert_equal 'komagata (Komagata Masaki): 管理者、メンター', @admin_mentor_user.icon_title
    assert_equal 'hajime (Hajime Tayo)', @student_user.icon_title
  end

  test '#long_name' do
    assert_equal 'Hajime Tayo (ハジメ タヨ)', @student_user.long_name
  end

  test '#enrollment_period' do
    assert_equal "<span> #{@student_user.elapsed_days}日目 </span><a href=\"/generations/#{@student_user.generation}\">#{@student_user.generation}期生</a>",
                 @student_user.enrollment_period

    assert_equal "<span> (#{l @graduated_user.graduated_on}卒業 #{@graduated_user.elapsed_days}日)" \
                  " </span><a href=\"/generations/#{@graduated_user.generation}\">#{@graduated_user.generation}期生</a>",
                 @graduated_user.enrollment_period
  end

  test '#roles_to_s' do
    assert_equal '管理者、メンター', @admin_mentor_user.roles_to_s
    assert_equal '', @student_user.roles_to_s
    assert_equal '卒業生', @graduated_user.roles_to_s
    assert_equal '管理者', @admin_user.roles_to_s
    assert_equal 'アドバイザー', @adviser_user.roles_to_s
    assert_equal 'メンター', @mentor_user.roles_to_s
    assert_equal '研修生', @trainee_user.roles_to_s
    assert_equal '退会ユーザー', @retired_user.roles_to_s
  end
end
