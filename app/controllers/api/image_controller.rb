# frozen_string_literal: true

class API::ImageController < API::BaseController
  def create
    @image = Image.new(user: current_user, file: params[:file])
    @image.strip_exif!

    if @image.save
      render :create, status: :created
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end
end
