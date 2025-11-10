# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'lp'
  DEFAULT_COURSE = 'Railsエンジニア'
  FAQ_CATEGORY_NAME_FOR_TRAINING = '企業研修代行について'
  FAQ_CATEGORY_NAME_FOR_CERTIFIED_RESKILL_COURSES = '給付制度対象講座について'
  FAQ_CATEGORY_NAME_FOR_JOB_SUPPORT = '就職について'

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
    @featured_articles = Article.featured
  end

  def alumni_voices
    @articles = Article.alumni_voices.page(params[:page])
  end

  def job_support
    @faqs = faqs_for(FAQ_CATEGORY_NAME_FOR_JOB_SUPPORT)
  end

  def pricing; end

  def faq
    @faq_categories = FaqCategory.order(:position).select do |faq_category|
      faq_category.faqs.present?
    end

    @faqs = if params[:category].present?
              faqs_for(params[:category])
            else
              FAQ.order(:position)
            end
  end

  def training
    @faqs = faqs_for(FAQ_CATEGORY_NAME_FOR_TRAINING)
  end

  def practices; end

  def tos; end

  def pp; end

  def law; end

  def coc; end

  def press_kit
    @press_releases = Article.press_releases(6)
  end

  def logo; end

  def rails_developer_course
    @faqs = faqs_for(FAQ_CATEGORY_NAME_FOR_CERTIFIED_RESKILL_COURSES)
    render template: 'welcome/certified_reskill_courses/rails_developer_course/index'
  end

  def choose_courses
    @rails_course = Course.preload(categories: :practices).find_by(title: 'Railsエンジニア')
    @frontend_course = Course.preload(categories: :practices).find_by(title: 'フロントエンドエンジニア')
  end

  private

  # TODO: リスキル講座 公開までは管理者のみ見れるようにするので、そのメソッド。
  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: 'ページのアクセス権限がありませんでした。'
  end

  def faqs_for(category_name)
    FaqCategory.find_by(name: category_name)&.faqs&.order(:position) || FAQ.none
  end
end
