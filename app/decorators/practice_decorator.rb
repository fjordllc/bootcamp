# frozen_string_literal: true

module PracticeDecorator
  OGP_IMAGE_SIZE = [1200, 630].freeze

  def ogp_image_url
    default_image_path = '/ogp/ogp.png'

    if ogp_image.attached?
      ogp_image.variant(resize_to_fill: OGP_IMAGE_SIZE, autorot: true, saver: { strip: true, quality: 60 }).processed.url
    else
      image_url default_image_path
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::InvariableError, Vips::Error
    image_url default_image_path
  end
end
