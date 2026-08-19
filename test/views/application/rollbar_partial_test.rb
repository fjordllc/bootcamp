# frozen_string_literal: true

require 'test_helper'

class RollbarPartialTest < ActionView::TestCase
  test 'does not report Chrome extension errors' do
    render partial: 'application/rollbar'

    assert_includes rendered, 'hostBlockList: ["^chrome-extension://"]'
  end
end
