# frozen_string_literal: true

class API::Watches::ToggleController < API::BaseController
  def index
    @watches = Watch.where(
      user: current_user,
      watchable: watchable
    )
  end

  def create
    if Watch.exists?(user_id: current_user.id, watchable_id: params[:watchable_id], watchable_type: params[:watchable_type])
      render json: { message: "この#{watchable.class.model_name.human}はWatch済です。" }, status: :unprocessable_entity
    else
      @watch = Watch.create!(
        user: current_user,
        watchable: watchable
      )
      render json: @watch
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
