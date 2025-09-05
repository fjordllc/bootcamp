# frozen_string_literal: true

module PageTabs
  module ReportsHelper
    def report_page_tabs(active_tab:)
      tabs = []
      tabs << { name: '日報', link: reports_path, badge: admin_or_mentor_login? ? Cache.unchecked_report_count.presence : nil }
      tabs << { name: 'みんなのブログ', link: external_entries_path }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
