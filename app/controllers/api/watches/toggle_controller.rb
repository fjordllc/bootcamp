# frozen_string_literal: true

class Api::Watches::ToggleController < Api::BaseController
  def index
    @watches = Watch.where(
      user: current_user,
      watchable:
    )
  end

  private

  def watchable
    params[:watchable_type].constantize.find_by(id: params[:watchable_id])
  end
end
