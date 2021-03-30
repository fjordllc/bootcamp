# frozen_string_literal: true

class WatchesController < ApplicationController
  before_action :require_login

  PAGINATES_PER = 25
  def index
    user_watching = current_user.watches.preload(:watchable).order(created_at: :desc).map(&:watchable)
    @watches = Kaminari.paginate_array(user_watching).page(params[:page]).per(PAGINATES_PER)
  end
end
