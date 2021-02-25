# frozen_string_literal: true

class WatchesController < ApplicationController
  before_action :require_login
  def index
    user_watching = current_user.watches.order(created_at: :desc)
    @watches = user_watching.page(params[:page]).per(25)
  end
end
