# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'welcome'
  DEFAULT_COURSE = 'Railsプログラマー'

  def index
    @mentors = User.mentors_sorted_by_created_at
  end

  def pricing; end

  def faq; end

  def training; end

  def practices
    @categories = Course.find_by(title: DEFAULT_COURSE).categories.preload(:practices).order(:position)
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
end
