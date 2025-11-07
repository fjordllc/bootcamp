# frozen_string_literal: true

class API::ImageController < API::BaseController
  def create
    @image = Image.new(user: current_user, image: params[:file])
    if @image.save
      begin
        strip_exif
        render :create, status: :created
      rescue StandardError => e
        Rails.logger.error("Failed to strip EXIF: #{e.message}")
        @image.destroy
        render json: { error: '画像処理に失敗しました' }, status: :unprocessable_entity
      end
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
    timestamp = Time.current.strftime('%Y%m%d%H%M%S%L')
    File.open(copied_image.path) do |file|
      original_image.attach(io: file, filename: "#{current_user.id}_#{timestamp}#{ext}")
    end
  ensure
    copied_image&.destroy!
  end
end
