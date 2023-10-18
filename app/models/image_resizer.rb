# frozen_string_literal: true

class ImageResizer
  OGP_SIZE = [1200, 630].freeze

  def initialize(attached_one)
    @attached_one = attached_one
    @transformation = ImageResizerTransformation.new
  end

  def fit_to!(width, height)
    return nil if just_fit_to_size?(width, height)

    original_width, original_height = original_size

    fitted = @attached_one.variant(**@transformation.fit_to(original_width, original_height, width, height))
                          .processed
                          .image.blob

    # 変形前の画像関連データの削除にpurge、purge_laterは不要。
    # データの削除はattachで担える
    @attached_one.attach(fitted)
  end

  def just_fit_to_size?(width, height)
    original_width, original_height = original_size
    width == original_width && height == original_height
  end

  private

  def original_size
    blob = @attached_one.blob
    blob.analyze unless blob.analyzed?
    [blob.metadata[:width], blob.metadata[:height]]
  end
end
