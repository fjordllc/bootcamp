# frozen_string_literal: true

module PageTabs
  module DashboardHelper
    def dashboard_page_tabs(active_tab:)
      tabs = []
      tabs << { name: 'ダッシュボード', link: '/' }
      tabs << { name: '自分の日報', link: current_user_reports_path, count: current_user.reports.length }
      tabs << { name: '自分の提出物', link: current_user_products_path, count: current_user.products.length }
      tabs << { name: 'ブックマーク', link: current_user_bookmarks_path, count: current_user.bookmarks.length }
      tabs << { name: 'Watch中', link: current_user_watches_path }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
