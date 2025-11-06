# frozen_string_literal: true

class API::ImageController < API::BaseController
  def create
    @image = Image.new(user: current_user, image: params[:file])
    if @image.save
      strip_exif
      render :create, status: :created
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  private

  def strip_exif
    original_image = @image.image
    copied_image = MiniMagick::Image.read(original_image.download)
    copied_image.strip

    ext = File.extname(original_image.filename.to_s)
    original_image.attach(io: File.open(copied_image.path), filename: "#{current_user.id}#{ext}")
  end
end
