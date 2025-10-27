# frozen_string_literal: true

require 'test_helper'

class ProductsHelperTest < ActionView::TestCase
  test 'unconfirmed_links_label returns correct label for all targets' do
    assert_equal '全ての提出物を一括で開く', unconfirmed_links_label('all')
    assert_equal '未完了の提出物を一括で開く', unconfirmed_links_label('unchecked')
    assert_equal '未完了の提出物を一括で開く', unconfirmed_links_label('unchecked_all')
    assert_equal '未返信の提出物を一括で開く', unconfirmed_links_label('unchecked_no_replied')
    assert_equal '未アサインの提出物を一括で開く', unconfirmed_links_label('unassigned')
    assert_equal '自分の担当の提出物を一括で開く', unconfirmed_links_label('self_assigned')
    assert_equal '自分の担当の提出物を一括で開く', unconfirmed_links_label('self_assigned_all')
    assert_equal '未返信の担当の提出物を一括で開く', unconfirmed_links_label('self_assigned_no_replied')
  end

  test 'unconfirmed_links_label returns empty string for unknown target' do
    assert_equal '', unconfirmed_links_label('unknown')
    assert_equal '', unconfirmed_links_label(nil)
  end
end
