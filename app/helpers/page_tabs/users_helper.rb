# frozen_string_literal: true

module PageTabs
  module UsersHelper
    def user_page_tabs(user, active_tab:)
      comment_count = user.comments.without_talk.length
      tabs = []
      tabs << { name: 'プロフィール', link: user_path(user) }
      tabs << { name: 'ポートフォリオ', link: user_portfolio_path(user) }
      tabs << { name: '日報', link: user_reports_path(user), count: user.reports.length }
      tabs << { name: 'コメント', link: user_comments_path(user), count: comment_count }
      tabs << { name: '提出物', link: user_products_path(user), count: user.products.length }
      tabs << { name: '質問', link: user_questions_path(user), count: user.questions.length }
      tabs << { name: '回答', link: user_answers_path(user), count: user.answers.length }
      tabs << { name: '相談部屋', link: talk_path(user.talk) } if current_user.admin? && !user.admin?
      render PageTabsComponent.new(tabs:, active_tab:)
    end

    def users_page_tabs(active_tab:)
      tabs = []
      tabs << { name: '全て', link: users_path }
      tabs << { name: 'コース別', link: users_courses_path }
      tabs << { name: '期生別', link: generations_path }
      tabs << { name: 'タグ別', link: users_tags_path }
      tabs << { name: 'フォロー中', link: users_path(target: 'followings') }
      tabs << { name: '企業別', link: users_companies_path }
      tabs << { name: '都道府県別', link: users_areas_path }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
