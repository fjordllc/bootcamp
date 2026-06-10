# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'pjord_ai_badge returns AI badge for Pjord' do
    badge = pjord_ai_badge(users(:pjord))

    assert_includes badge, 'AI'
    assert_includes badge, 'AIアシスタント'
    assert_includes badge, 'a-badge'
  end

  test 'pjord_ai_badge returns nil for other users' do
    assert_nil pjord_ai_badge(users(:komagata))
  end
end
