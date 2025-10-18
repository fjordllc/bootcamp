# frozen_string_literal: true

require 'test_helper'

class AfterUserRetirementTest < ActiveSupport::TestCase
  setup do
    @methods_called = []
    @user = users(:kimura)
  end

  def stub_newspaper
    methods_called = @methods_called

    Newspaper.define_singleton_method(:publish) do |_event, _payload|
      methods_called << :newspaper
    end
  end

  def stub_methods(retirement)
    methods_called = @methods_called

    %i[destroy_subscription notify_all destroy_card].each do |method_name|
      retirement.define_singleton_method(method_name) do |_arg = nil|
        methods_called << method_name
      end
    end
  end

  test 'call method runs expected methods when triggered by user' do
    methods_called = @methods_called
    retirement = AfterUserRetirement.new(@user, triggered_by: 'user')

    stub_newspaper
    stub_methods(retirement)

    @user.define_singleton_method(:clear_github_data) do
      methods_called << :clear_github_data
    end

    retirement.call

    expected_methods = %i[
      newspaper
      destroy_subscription
      notify_all
      destroy_card
      clear_github_data
    ]

    assert_equal expected_methods, @methods_called
  end

  test 'call method runs expected methods when triggered by hibernation' do
    retirement = AfterUserRetirement.new(@user, triggered_by: 'hibernation')

    stub_newspaper
    stub_methods(retirement)

    retirement.call

    expected_methods = %i[
      newspaper
      destroy_subscription
      notify_all
    ]

    assert_equal expected_methods, @methods_called
  end

  test 'call method runs expected methods when triggered by admin' do
    retirement = AfterUserRetirement.new(@user, triggered_by: 'admin')

    stub_newspaper
    stub_methods(retirement)

    retirement.call

    expected_methods = %i[
      newspaper
      destroy_subscription
    ]

    assert_equal expected_methods, @methods_called
  end
end
