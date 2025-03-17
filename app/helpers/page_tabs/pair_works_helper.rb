# frozen_string_literal: true

module PageTabs
  module PairWorksHelper
    def pair_works_page_tabs
      tabs = []
      tabs << { name: '相手募集中', link: pair_works_path(target: 'not_solved'), badge: PairWork.not_solved.not_wip.size }
      tabs << { name: '相手確定', link: pair_works_path(target: 'solved') }
      tabs << { name: '全て', link: pair_works_path }
      render PageTabsComponent.new(tabs:, active_tab: pair_work_active_tab)
    end

    private

    def pair_work_active_tab
      case params[:target]
      when 'not_solved'
        '相手募集中'
      when 'solved'
        '相手確定'
      else
        '全て'
      end
    end
  end
end
