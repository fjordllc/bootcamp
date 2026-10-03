# frozen_string_literal: true

require 'test_helper'

class McpOauth::PreAuthorizationTest < ActiveSupport::TestCase
  test 'validations match Doorkeeper::OAuth::PreAuthorization' do
    # Doorkeeper keeps validations in a per-class ivar and the subclass copies
    # the list at load time; a Doorkeeper upgrade that changes the parent list
    # must surface here instead of silently dropping checks.
    assert_equal Doorkeeper::OAuth::PreAuthorization.validations,
                 McpOauth::PreAuthorization.validations
  end
end
