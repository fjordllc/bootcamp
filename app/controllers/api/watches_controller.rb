# frozen_string_literal: true

class API::WatchesController < API::BaseController
  include Rails.application.routes.url_helpers

  def index
    @watches = Watch.where(user: current_user).preload(:watchable).order(created_at: :desc).page(params[:page])
  end
end
