# frozen_string_literal: true

module PageTabs
  module TalksHelper
    def talks_page_tabs(active_tab:)
      uncompleted_badge = current_user.admin_or_mentor? ? Talk.action_uncompleted.count : nil
      tabs = []
      tabs << { name: '未対応', link: talks_action_uncompleted_index_path, badge: uncompleted_badge }
      tabs << { name: '全て', link: talks_path }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
