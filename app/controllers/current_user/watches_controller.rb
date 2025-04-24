# frozen_string_literal: true

class CurrentUser::WatchesController < ApplicationController
  before_action :set_user
  before_action :set_watches

  def index
    page_number = params[:page]&.to_i
    per_page = Kaminari.config.default_per_page
    @next_watch_index = page_number.nil? ? per_page : per_page * page_number
    @all_ids = Watch.where(user: current_user).order(created_at: :desc).pluck(:id)
  end

  private

  def set_user
    @user = current_user
  end

  def set_watches
    @watches = user.watches.preload(watchable: [:user]).order(created_at: :desc).page(params[:page])
  end

  def user
    @user ||= current_user
  end
end
