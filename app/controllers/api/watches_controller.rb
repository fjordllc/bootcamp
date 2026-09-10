# frozen_string_literal: true

class API::WatchesController < API::BaseController
  include Rails.application.routes.url_helpers

  def index
    @current_page = params[:page]
    @watches = current_user.watches.preload(watchable: [:user]).order(created_at: :desc).page(params[:page])
    render partial: 'watches/watches', locals: { watches: @watches }
  end
end
