# frozen_string_literal: true

require 'test_helper'

class UserDecoratorTest < ActiveSupport::TestCase
  def setup
    @user1 = ActiveDecorator::Decorator.instance.decorate(users(:komagata))
    @user2 = ActiveDecorator::Decorator.instance.decorate(users(:hajime))
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

  test '#format_user_to_channel' do
    expected = %i[id login_name path role icon_title avatar_url]
    assert_equal expected, @user1.format_to_channel.keys
  end
end
