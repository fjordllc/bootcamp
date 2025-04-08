# frozen_string_literal: true

class API::WatchesController < API::BaseController
  include Rails.application.routes.url_helpers

  def show
    @watch = Watch.find(params[:id])
    render partial: 'watches/watch', locals: { watch: @watch }
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
