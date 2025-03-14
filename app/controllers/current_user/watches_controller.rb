# frozen_string_literal: true

class CurrentUser::WatchesController < ApplicationController
  before_action :set_user
  before_action :set_watches

  def index; end

  private

  def set_user
    @user = current_user
  end

  def set_watches
    @watches = user.watches.preload(:watchable).order(created_at: :desc).page(params[:page])
  end

  def user
    @user ||= current_user
  end
end
