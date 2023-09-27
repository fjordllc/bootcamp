# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'welcome'

  def index
    @mentors = current_user ? User.mentors_sorted_by_created_at : User.visible_sorted_mentors
  end

  def pricing
    render layout: 'lp'
  end

  def faq
    render layout: 'lp'
  end

  def training
    render layout: 'lp'
  end

  def practices
    render layout: 'lp'
  end

  def tos
    render layout: 'lp'
  end

  def pp
    render layout: 'lp'
  end

  def law
    render layout: 'lp'
  end

  def coc
    render layout: 'lp'
  end

  def courses
    @courses = Course.order(:created_at)
  end
end
