# frozen_string_literal: true

require_dependency 'faq_category'
class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'lp'
  DEFAULT_COURSE = 'Railsエンジニア'

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
  end

  def alumni_voices; end

  def job_support; end

  def pricing; end

  def faq
    if params[:category].present?
      category = FAQCategory.find_by(name: params[:category])
      @faqs = category.present? ? FAQ.where(faq_category_id: category.id).order(:created_at) : FAQ.none
    else
      @faqs = FAQ.all.order(:created_at)
    end
  end

  def training; end

  def practices; end

  def tos; end

  def pp; end

  def law; end

  def coc; end

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
