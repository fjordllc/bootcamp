# frozen_string_literal: true

require 'test_helper'

class UserRegistrationNotifierTest < ActiveSupport::TestCase
  def setup
    @user = users(:kimura)
    @user_url = 'https://example.com/users/1'
    @decorated_user = ActiveDecorator::Decorator.instance.decorate(@user)
  end

  test 'includes user URL in chat notification' do
    expected_message = "#{@user.login_name}さん#{@decorated_user.roles_to_s.empty? ? '' : "（#{@decorated_user.roles_to_s}）"}が新たなメンバーとしてJOINしました🎉\r<#{@user_url}>"

    actual_message = nil

    ChatNotifier.stub(:message, ->(message) { actual_message = message }) do
      UserRegistrationNotifier.new.call(@user, @user_url)
    end

    assert_equal expected_message, actual_message
  end
end
