# frozen_string_literal: true

module PageTabs
  module PracticesHelper
    def practice_page_tabs(practice, active_tab:)
      tabs = []
      tabs << { name: 'プラクティス', link: practice_path(practice) }
      tabs << { name: '日報', link: practice_reports_path(practice), count: practice.reports.length }
      tabs << { name: '質問', link: practice_questions_path(practice), count: practice.questions.length }
      tabs << { name: 'Docs', link: practice_pages_path(practice), count: practice.pages.length }
      # TODO: 動画機能の完成時に本番環境で公開。動画リンクを隠した状態でのリリース。
      tabs << { name: '動画', link: practice_movies_path(practice), count: practice.movies.length } unless Rails.env.production?
      tabs << { name: '提出物', link: practice_products_path(practice) }
      tabs << { name: '模範解答', link: practice_submission_answer_path(practice) } if practice.submission_answer.present?
      tabs << { name: 'コーディングテスト', link: practice_coding_tests_path(practice) } if practice.coding_tests.present?
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
