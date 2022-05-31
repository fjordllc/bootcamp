# frozen_string_literal: true

require 'test_helper'

class UserDecoratorTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  def setup
    ActiveDecorator::ViewContext.push(controller.view_context)
    @user1 = ActiveDecorator::Decorator.instance.decorate(users(:komagata))
    @user2 = ActiveDecorator::Decorator.instance.decorate(users(:hajime))
    @user3 = ActiveDecorator::Decorator.instance.decorate(users(:sotugyou))
  end

  test 'staff_roles' do
    assert_equal '管理者、メンター', @user1.staff_roles
    assert_equal '', @user2.staff_roles
  end

  test 'icon_title' do
    assert_equal 'komagata (Komagata Masaki): 管理者、メンター', @user1.icon_title
    assert_equal 'hajime (Hajime Tayo)', @user2.icon_title
  end

  test 'long_name' do
    assert_equal 'hajime (Hajime Tayo)', @user2.long_name
  end

  test 'enrollment_period' do
    assert_equal "<span> #{@user2.elapsed_days}日目 </span><a href=\"/generations/#{@user2.generation}\">#{@user2.generation}期生</a>", @user2.enrollment_period
    assert_equal "<span> (#{l @user3.graduated_on}卒業 #{@user3.elapsed_days}日) </span><a href=\"/generations/#{@user3.generation}\">#{@user2.generation}期生</a>", @user3.enrollment_period
  end
end
