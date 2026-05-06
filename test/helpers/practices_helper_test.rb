# frozen_string_literal: true

require 'test_helper'

class PracticesHelperTest < ActionView::TestCase
  test 'difficulty_icon' do
    assert_equal '', difficulty_icon(nil)
    assert_equal '🔥', difficulty_icon(0)
    assert_equal '🔥', difficulty_icon(300)
    assert_equal '🔥🔥', difficulty_icon(301)
    assert_equal '🔥🔥', difficulty_icon(600)
    assert_equal '🔥🔥🔥', difficulty_icon(601)
    assert_equal '🔥🔥🔥', difficulty_icon(900)
    assert_equal '🔥🔥🔥🔥', difficulty_icon(901)
    assert_equal '🔥🔥🔥🔥', difficulty_icon(1200)
    assert_equal '🔥🔥🔥🔥🔥', difficulty_icon(1201)
  end
end
