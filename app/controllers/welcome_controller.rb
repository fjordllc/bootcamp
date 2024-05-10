# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'welcome'
  DEFAULT_COURSE = 'Railsエンジニア'

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
  end

  def pricing; end

  def faq
    category_id = FAQ.categories[:"#{params[:category]}"]
    @faqs = if params[:category].present?
              FAQ.where(category: category_id)
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

  def courses
    @courses = Course.order(:created_at)
  end
end
