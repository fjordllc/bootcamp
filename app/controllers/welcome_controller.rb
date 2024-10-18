# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'lp'
  DEFAULT_COURSE = 'Railsエンジニア'

  # TODO: リスキル講座 公開までは管理者のみ見れるようにする
  before_action :require_admin, only: %i[
    rails_developer_course
    rails_developer_course_regulations
  ]

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
  end

  def alumni_voices; end

  def job_support; end

  def certified_reskill_courses; end

  def pricing; end

  def faq; end

  def training; end

  def practices; end

  def tos; end

  def pp; end

  def law; end

  def coc; end

  def rails_developer_course
    render template: 'welcome/certified_reskill_courses/rails_developer_course/index'
  end

  def rails_developer_course_regulations
    render template: 'welcome/certified_reskill_courses/rails_developer_course/regulations'
  end

  private

  # TODO: リスキル講座 公開までは管理者のみ見れるようにするので、そのメソッド。
  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: 'ページのアクセス権限がありませんでした。'
  end
end
