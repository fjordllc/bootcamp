# frozen_string_literal: true

require_dependency 'faq_category'
class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'lp'
  DEFAULT_COURSE = 'Railsエンジニア'
  FAQ_CATEGORY_NAME = '企業研修代行について'

  ##
  # Assigns a list of mentors to @mentors, showing all mentors for logged-in users or only visible mentors for guests.
  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
  end

  def alumni_voices
    @articles = Article.alumni_voices.page(params[:page])
  end

  def job_support; end

  def pricing; end

  ##
  # Loads FAQ categories that have associated FAQs and retrieves FAQs for a selected category or all FAQs if no category is specified.
  # If a category parameter is provided, only FAQs from that category are loaded; otherwise, all FAQs are loaded and ordered by position.
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

  ##
  # Loads FAQs related to the training FAQ category into @faqs, or an empty array if the category is not found.
  def training
    @faqs = FAQCategory.find_by(name: FAQ_CATEGORY_NAME)&.faqs || []
  end

  ##
# Renders the practices page.
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
end
