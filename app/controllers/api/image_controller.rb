# frozen_string_literal: true

class API::ImageController < API::BaseController
  def create
    @image = Image.new(user: current_user, image: params[:file])

    if @image.save
      render :create, status: :created
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end
end
