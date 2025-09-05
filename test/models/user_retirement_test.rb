# frozen_string_literal: true

require 'test_helper'

class AfterUserRetirementTest < ActiveSupport::TestCase
  test 'call method performs all retirement steps' do
    user = users(:kimura)
    retirement = AfterUserRetirement.new(user, triggered_by: 'user')

    methods_called = []

    user.define_singleton_method(:clear_github_data) do
      methods_called << :clear_github_data
    end

    %i[destroy_subscription destroy_card].each do |method_name|
      retirement.define_singleton_method(method_name) do
        methods_called << method_name
      end
    end

    retirement.define_singleton_method(:notify_all) do |_event|
      methods_called << :notify_all
    end

    retirement.call

    expected_methods = %i[
      destroy_subscription
      notify_all
      destroy_card
      clear_github_data
    ]

    assert_equal expected_methods, methods_called
  end
end
