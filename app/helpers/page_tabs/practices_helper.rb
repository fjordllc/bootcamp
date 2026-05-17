# frozen_string_literal: true

module PageTabs
  module PracticesHelper
    def practice_page_tabs(practice, active_tab:, include_source: nil)
      # include_source未指定(nil)時は、給付金コースならtrue
      include_source = practice.grant_course? if include_source.nil?
      tabs = []
      tabs << { name: 'プラクティス', link: practice_path(practice) }
      tabs << { name: '日報', link: practice_reports_path(practice), count: practice.reports_count(include_source:) }
      tabs << { name: '質問', link: practice_questions_path(practice), count: practice_questions_count(practice, active_tab:) }
      tabs << { name: 'Docs', link: practice_pages_path(practice), count: practice.pages.count }
      tabs << { name: '動画', link: practice_movies_path(practice), count: practice.movies.count } if movie_available?
      tabs << { name: '提出物', link: practice_products_path(practice) } if practice.submission
      tabs << { name: '模範解答', link: practice_submission_answer_path(practice) } if practice.submission_answer.present?
      tabs << { name: 'コーディングテスト', link: practice_coding_tests_path(practice) } if practice.coding_tests.present?
      render PageTabsComponent.new(tabs:, active_tab:)
    end

    private

    def practice_questions_count(practice, active_tab:)
      practices =
        if active_tab == '質問' && params[:scope] == 'grant_course'
          [practice]
        else
          [practice, practice.source_practice].compact
        end

      Question.where(practice: practices).count
    end
  end
end
