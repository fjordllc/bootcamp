# frozen_string_literal: true

require 'test_helper'

class LabelHelperTest < ActionView::TestCase
  test '#bookmarkable_label' do
    event = bookmarks(:bookmark34).bookmarkable
    assert_dom_equal bookmarkable_label(event), '特別<br>イベント'

    regular_event = bookmarks(:bookmark33).bookmarkable
    assert_dom_equal bookmarkable_label(regular_event), '定期<br>イベント'

    report = bookmarks(:bookmark_report).bookmarkable
    assert_dom_equal bookmarkable_label(report), '日報'
  end
end
