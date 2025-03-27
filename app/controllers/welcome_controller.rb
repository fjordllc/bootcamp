# frozen_string_literal: true

require_dependency 'faq_category'
class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'lp'
  DEFAULT_COURSE = 'Railsエンジニア'
  FAQ_CATEGORY_NAME = '法人利用について'

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
    @featured_articles = Article.featured
  end

  def alumni_voices; end

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
    @faqs = FAQCategory.find_by(name: FAQ_CATEGORY_NAME).faqs
  end

  def practices; end

  def tos; end

  def pp; end

  def law; end

  def coc; end

  def press_kit; end

  def logo; end

  def rails_developer_course
    render template: 'welcome/certified_reskill_courses/rails_developer_course/index'
  end

  private

  # TODO: リスキル講座 公開までは管理者のみ見れるようにするので、そのメソッド。
  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: 'ページのアクセス権限がありませんでした。'
  end
end
