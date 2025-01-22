# frozen_string_literal: true

module PageTabs
  module EventsHelper
    def events_page_tabs(active_tab:)
      tabs = []
      tabs << { name: '特別イベント', link: events_path }
      tabs << { name: '定期イベント', link: regular_events_path(target: 'not_finished') }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
