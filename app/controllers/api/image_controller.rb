# frozen_string_literal: true

class API::ImageController < API::BaseController
  def create
    @image = Image.new(user: current_user)
    processed_image = ExifStripper.call(params[:file])
    @image.image.attach(processed_image)

    if @image.save
      render :create, status: :created
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end
end
