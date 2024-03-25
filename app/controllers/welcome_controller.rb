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
    @faqs = if params[:category].present?
              category = FaqsCategory.find_by(name: params[:category])
              FAQ.where(faqs_categories_id: category.id) if category.present?
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
