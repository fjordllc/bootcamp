# frozen_string_literal: true

class API::Watches::ToggleController < API::BaseController
  def index
    @watches = Watch.where(
      user: current_user,
      watchable:
    )
    render json: @watches
  end

  private

  def watchable
    params[:watchable_type].constantize.find_by(id: params[:watchable_id])
  end
end
