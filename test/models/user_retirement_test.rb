# frozen_string_literal: true

require 'test_helper'

class UserRetirementTest < ActiveSupport::TestCase
  test 'execute method performs all retirement steps' do
    user = users(:kimura)
    retirement = UserRetirement.new(user)

    methods_called = []

    user.define_singleton_method(:clear_github_data) do
      methods_called << :clear_github_data
    end

    %i[destroy_subscription destroy_card notify_to_user notify_to_admins notify_to_mentors].each do |method_name|
      retirement.define_singleton_method(method_name) do
        methods_called << method_name
      end
    end

    retirement.execute

    expected_methods = %i[
      clear_github_data
      destroy_subscription
      destroy_card
      notify_to_user
      notify_to_admins
      notify_to_mentors
    ]

    assert_equal expected_methods, methods_called
  end
end
