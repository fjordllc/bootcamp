# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  test 'return whether talk' do
    user = users(:kimura)
    assert talk?(user)

    user = users(:taikai3)
    assert_not talk?(user)
  end
end
