# frozen_string_literal: true

require 'test_helper'

class RetirementTest < ActiveSupport::TestCase
  setup do
    @user = users(:hajime)
  end

  test 'execute calls all the necessary methods' do
    retirement = Retirement.by_self({}, user: @user)

    expected_methods = %i[
      assign_reason
      assign_date
      clear_hibernation_state
      save_user
      destroy_subscription
      cancel_event_subscription
      remove_as_event_organizer
      clear_github_info
      destroy_cards
      trigger_retirement_event
      notify
    ]

    called_methods = []
    expected_methods.each do |method|
      retirement.define_singleton_method(method) do
        called_methods << method
      end
    end

    retirement.execute

    assert_equal expected_methods, called_methods
  end

  test 'self retirement assigns retirement reason and notification type correctly' do
    retire_reason = '退会の理由'
    param = { satisfaction: 1, retire_reason: }

    retirement = Retirement.by_self(param, user: @user)
    strategy = retirement.instance_variable_get(:@strategy)

    retirement.execute

    assert_equal @user.retire_reason, retire_reason
    assert_equal strategy.notification_type, :retire
  end

  test 'auto retirement assigns retirement reason and notification type correctly' do
    retirement = Retirement.auto(user: @user)
    strategy = retirement.instance_variable_get(:@strategy)

    retirement.execute

    assert_equal @user.retire_reason, '（休会後三ヶ月経過したため自動退会）'
    assert_equal strategy.notification_type, :auto_retire
  end

  test 'admin retirement does not assign retirement reason or notification type' do
    retirement = Retirement.by_admin(user: @user)
    strategy = retirement.instance_variable_get(:@strategy)

    retirement.execute

    assert_nil @user.retire_reason
    assert_nil strategy.notification_type
  end

  test 'rolls back user update if save_user fails' do
    retirement = Retirement.by_self({}, user: @user)
    retirement.define_singleton_method(:save_user) do
      raise ActiveRecord::RecordInvalid.new, 'This is an exception'
    end

    retirement.execute
    @user.reload

    assert_nil @user.retired_on
  end

  test 'rolls back user update if Stripe update fails' do
    retirement = Retirement.by_self({}, user: @user)
    retirement.define_singleton_method(:destroy_subscription) do
      raise Stripe::StripeError.new, 'This is an exception'
    end

    retirement.execute
    @user.reload

    assert_nil @user.retired_on
  end
end
