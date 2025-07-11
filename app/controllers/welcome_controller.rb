# frozen_string_literal: true

require_dependency 'faq_category'
class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'lp'
  DEFAULT_COURSE = 'Railsエンジニア'
  FAQ_CATEGORY_NAME_FOR_TRAINING = '企業研修代行について'
  FAQ_CATEGORY_NAME_FOR_CERTIFIED_RESKILL_COURSES = '給付制度対象講座について'

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
    @articles = list_articles_with_specific_tag
  end

  def alumni_voices
    @articles = Article.alumni_voices.page(params[:page])
  end

  def job_support; end

  def pricing; end

  def faq
    @faq_categories = FAQCategory.order(:position).select do |faq_category|
      faq_category.faqs.present?
    end

    if params[:category].present?
      faq_category = FAQCategory.find_by(name: params[:category])
      @faqs = faq_category.faqs
    else
      @faqs = FAQ.order(:position)
    end
  end

  def training
    category = FAQCategory.find_by(name: FAQ_CATEGORY_NAME_FOR_TRAINING)
    @faqs = category&.faqs || FAQ.none
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
    category = FAQCategory.find_by(name: FAQ_CATEGORY_NAME_FOR_CERTIFIED_RESKILL_COURSES)
    @faqs = category&.faqs || FAQ.none
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

  def list_articles_with_specific_tag
    Article.tagged_with('注目の記事').order(published_at: :desc).where(wip: false).first(6)
  end
end
