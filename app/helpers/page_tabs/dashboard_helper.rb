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
      if Rails.env.in? %w[development test]
        tabs << { name: '分報',
                  link: "#{current_user_micro_reports_path(page: current_user.latest_micro_report_page)}#latest-micro-report",
                  count: current_user.micro_reports.length }
      end
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
