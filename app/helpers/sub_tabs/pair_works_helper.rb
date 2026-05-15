# frozen_string_literal: true

module SubTabs
  module PairWorksHelper
    def pair_works_sub_tabs
      tabs = []
      tabs << { name: 'ペア募集中', link: pair_works_path(target: 'not_solved'), badge: PairWork.unsolved_badge(current_user:) }
      tabs << { name: 'ペア確定', link: pair_works_path(target: 'solved') }
      tabs << { name: '全て', link: pair_works_path }
      render SubTabsComponent.new(tabs:, active_tab: pair_work_active_tab)
    end

    private

    def pair_work_active_tab
      case params[:target]
      when 'not_solved'
        'ペア募集中'
      when 'solved'
        'ペア確定'
      else
        '全て'
      end
    end
  end
end
