# frozen_string_literal: true

class API::WatchesController < API::BaseController
  include Rails.application.routes.url_helpers

  def show
    @watch = Watch.find(params[:id])
    render partial: 'watches/watch', locals: { watch: @watch }
  end
end
