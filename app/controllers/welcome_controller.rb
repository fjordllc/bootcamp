# frozen_string_literal: true

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
    category_id = FAQ.categories[:"#{params[:category]}"]
    @faqs = if params[:category].present?
              FAQ.where(category: category_id) if category_id.present?
            else
              FAQ.all
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
