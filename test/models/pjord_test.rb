# frozen_string_literal: true

require 'test_helper'

class PjordTest < ActiveSupport::TestCase
  test '.user returns pjord user' do
    assert_equal 'pjord', Pjord.user.login_name
  end
end
