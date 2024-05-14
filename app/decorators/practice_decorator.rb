# frozen_string_literal: true

module PracticeDecorator
  OGP_IMAGE_SIZE = [1200, 630].freeze

  def ogp_image_url
    ogp_image.variant(resize_to_fill: OGP_IMAGE_SIZE).processed.url if ogp_image.attached?
  end
end
