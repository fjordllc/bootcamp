# frozen_string_literal: true

class ImageResizer
  def initialize(attachment, resize_side: { width: 600, height: 600 }, options: {})
    @attachment = attachment
    @resize_side = resize_side
    @options = options
  end

  def resize
    @image_side = fetch_image_side
    resize_size = fetch_resize_size_fit_and_crop
    @attachment.variant(resize_to_fit: resize_size[:fit], crop: [*resize_size[:crop], @resize_side[:width], @resize_side[:height]], **@options)
  end

  private

  def fetch_image_side
    @attachment.blob.analyze unless @attachment.blob.analyzed?

    blob = @attachment.blob
    width = blob.metadata['width']
    height = blob.metadata['height']

    { width:, height: }
  end

  def fetch_resize_size_fit_and_crop
    aspect_ratio = @image_side[:width].to_f / @image_side[:height]
    if aspect_ratio > 1
      # 横長の画像の場合
      calculate_resize_size_fit_and_crop(:width)
    else
      # 縦長の画像の場合
      calculate_resize_size_fit_and_crop(:height)
    end
  end

  def calculate_resize_size_fit_and_crop(long_side)
    image_size = {}
    case long_side
    when :width
      resized_width = (@resize_side[:width] * @image_side[:width].to_f / @image_side[:height]).ceil
      image_size[:fit] = [resized_width, @resize_side[:height]]

      cut_out_start_point = (resized_width - @resize_side[:width]) / 2
      image_size[:crop] = [cut_out_start_point.floor, 0]
    when :height
      resized_height = (@resize_side[:height] * @image_side[:height].to_f / @image_side[:width]).ceil
      image_size[:fit] = [@resize_side[:width], resized_height]

      cut_out_start_point = (resized_height - @resize_side[:height]) / 2
      image_size[:crop] = [0, cut_out_start_point.floor]
    end
    image_size
  end
end
