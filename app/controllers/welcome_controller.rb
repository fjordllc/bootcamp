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

  def certified_reskill_courses; end

  def pricing; end

  def faq; end

  def training; end

  def practices; end

  def tos; end

  def pp; end

  def law; end

  def coc; end
end
