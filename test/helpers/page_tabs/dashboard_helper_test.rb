# frozen_string_literal: true

require 'test_helper'

class PageTabs::DashboardHelperTest < ActionView::TestCase
  include PageTabs::DashboardHelper

  def current_user; end

  test 'dashboard tabs count all records including drafts without loading histories' do
    user = users(:kimura)
    expected = { reports: user.reports.count, products: user.products.count, bookmarks: user.bookmarks.count }
    assert user.products.where(wip: true).exists?
    user.reload

    stub(:current_user, user) do
      html = dashboard_page_tabs(active_tab: 'ダッシュボード')
      assert_includes html, "自分の日報 （#{expected[:reports]}）"
      assert_includes html, "自分の提出物 （#{expected[:products]}）"
      assert_includes html, "ブックマーク （#{expected[:bookmarks]}）"
    end

    expected.each_key { |association| assert_not user.association(association).loaded?, "#{association} history was loaded" }
  end

  test 'dashboard tabs preserve empty counts' do
    user = users(:hajime)
    user.reports.destroy_all
    user.products.delete_all
    user.bookmarks.delete_all
    user.reload

    stub(:current_user, user) do
      html = dashboard_page_tabs(active_tab: 'ダッシュボード')
      assert_includes html, '自分の日報 （0）'
      assert_includes html, '自分の提出物 （0）'
      assert_includes html, 'ブックマーク （0）'
    end
  end
end
