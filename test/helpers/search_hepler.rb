# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  test 'return whether talk' do
    assert talk?(users(:kimura))
    assert_not talk?(users(:taikai3))
  end
end
