class API::FaceController < API::BaseController
  def update
    current_user.update(face: params[:face])

    if current_user.save
      render :show, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end
end
