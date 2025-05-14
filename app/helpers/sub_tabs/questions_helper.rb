# frozen_string_literal: true

module SubTabs
  module QuestionsHelper
    def questions_sub_tabs
      unsolved_badge = Question.unsolved_badge(current_user:, practice_id: params[:practice_id])
      tabs = []
      tabs << { name: '未解決', link: questions_path(target: 'not_solved'), badge: unsolved_badge }
      tabs << { name: '解決済み', link: questions_path(target: 'solved') }
      tabs << { name: '全て', link: questions_path }
      render SubTabsComponent.new(tabs:, active_tab: question_active_tab)
    end

    private

    def question_active_tab
      case params[:target]
      when 'not_solved'
        '未解決'
      when 'solved'
        '解決済み'
      else
        '全て'
      end
    end
  end
end
