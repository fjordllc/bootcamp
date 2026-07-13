# frozen_string_literal: true

class API::ImageController < API::BaseController
  def create
    uploaded_image = params[:file]
    MiniMagick::Image.new(uploaded_image.tempfile.path).strip if uploaded_image
    @image = Image.new(user: current_user, image: uploaded_image)

    if @image.save
      render :create, status: :created
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end
end
