# frozen_string_literal: true

class PracticesController < ApplicationController
  before_action :set_practice, only: %i[show]
  skip_before_action :require_active_user_login, only: %i[show]

  def show
    @categories = @practice.categories
    @tweet_url = @practice.tweet_url(practice_completion_url(@practice.id))
    @common_page = Page.find_by(slug: 'practice_common_description')
    @common_page = nil if @common_page&.wip?

    if logged_in?
      render :show
    else
      render :unauthorized_show, layout: 'not_logged_in'
    end
  end

  private

  def set_practice
    @practice = Practice.find(params[:id])
  end
end
