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

  def certified_reskill_courses; end

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
end
