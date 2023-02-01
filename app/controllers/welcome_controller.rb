# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  layout 'welcome'

  def index
    @mentors = User.mentors_sorted_by_created_at
  end

  def pricing; end

  def faq; end

  def training; end

  def practices
    @categories = Course.first.categories.preload(:practices).order(:position)
  end

  def tos; end

  def pp; end

  def law; end

  def coc; end
end
