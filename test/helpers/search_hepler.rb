# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  test 'return whether talk' do
    user = users(:kimura)
    assert true, talk?(user)

    user = users(:taikai3)
    assert_not false, talk?(user)
  end
end
