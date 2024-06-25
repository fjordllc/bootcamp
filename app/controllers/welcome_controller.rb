# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'welcome'

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
  end

  def pricing; end

  def faq; end

  def training; end

  def practices
    @categories = Course.find_by(title: Course::DEFAULT_COURSE).categories.preload(:practices).order(:position)
  end

  def tos; end

  def pp; end

  def law; end

  def coc; end

  def courses
    @courses = Course.order(:created_at)
  end
end
