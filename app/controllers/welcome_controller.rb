# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'welcome'
  DEFAULT_COURSE = 'Railsプログラマー'

  def index
    @mentors = User.mentors_sorted_by_created_at
    @articles = list_articles_with_specific_tag
  end

  def pricing; end

  def faq; end

  def training; end

  def practices
    @categories = Course.find_by(title: DEFAULT_COURSE).categories.preload(:practices).order(:position)
  end

  def tos; end

  def pp; end

  def law; end

  def coc; end

  private

  def list_articles_with_specific_tag
    Article.tagged_with('feature').order(published_at: :desc)
  end
end
