# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'welcome'
  DEFAULT_COURSE = 'Railsプログラマー'

  def index
    @mentors = User.mentors_sorted_by_created_at
  end

  def pricing; end

  def faq
    @faqs = FAQ.default_order
  end

  def training; end

  def practices
    @categories = Course.find_by(title: DEFAULT_COURSE).categories.preload(:practices).order(:position)
  end

  def tos; end

  def pp; end

  def law; end

  def coc; end
end
