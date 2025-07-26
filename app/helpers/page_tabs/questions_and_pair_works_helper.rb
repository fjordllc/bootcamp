# frozen_string_literal: true

module PageTabs
  module QuestionsAndPairWorksHelper
    def questions_and_pair_works_page_tabs
      tabs = []
      tabs << { name: 'Q&A', link: questions_path(target: 'not_solved'), badge: Question.unsolved_badge(current_user:, practice_id: params[:practice_id]) }
      tabs << { name: 'ペアワーク', link: pair_works_path(target: 'not_solved'), badge: PairWork.unsolved_badge(current_user:) }
      render PageTabsComponent.new(tabs:, active_tab: question_and_pair_work_active_tab)
    end

    private

    def question_and_pair_work_active_tab
      case request.path
      when %r{\A/questions}
        'Q&A'
      when %r{\A/pair_works}
        'ペアワーク'
      end
    end
  end
end
