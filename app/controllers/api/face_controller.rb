# frozen_string_literal: true

class API::FaceController < API::BaseController
  def update
    if current_user.update(face: params[:face])
      render :show, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end
end
