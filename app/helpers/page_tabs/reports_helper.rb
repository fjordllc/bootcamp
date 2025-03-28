# frozen_string_literal: true

module PageTabs
  module ReportsHelper
    def report_page_tabs(active_tab:)
      tabs = []
      tabs << { name: '日報', link: reports_path }
      tabs << { name: '未チェックの日報', link: reports_unchecked_index_path, badge: Cache.unchecked_report_count } if staff_login?
      tabs << { name: 'みんなのブログ', link: external_entries_path }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
