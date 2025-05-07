# frozen_string_literal: true

class API::WatchesController < API::BaseController
  include Rails.application.routes.url_helpers

  def index
    @current_page = params[:page]
    @watches = current_user.watches.preload(watchable: [:user]).order(created_at: :desc).page(params[:page])
    render partial: 'watches/watches', locals: { watches: @watches }
  end

  def create
    watch_existence = Watch.exists?(
      user_id: current_user.id,
      watchable:
    )
    if watch_existence
      message = "この#{watchable.class.model_name.human}はWatch済です。"
      render json: { message: }, status: :unprocessable_entity
    else
      watch = Watch.create!(
        user: current_user,
        watchable:
      )
      render json: watch
    end
  end

  def destroy
    @watch = Watch.find(params[:id])
    @watch.destroy
    head :no_content
  end

  private

  def watchable
    params[:watchable_type].constantize.find_by(id: params[:watchable_id])
  end
end
