# frozen_string_literal: true

require 'test_helper'

class ImageResizerTest < ActiveSupport::TestCase
  test '.fit_to!' do
    article = articles(:article4)

    ImageResizer.new(article.thumbnail).fit_to!(*ImageResizer::OGP_SIZE)

    article.thumbnail.blob.analyze unless article.thumbnail.blob.analyzed?
    assert_equal({ width: 1200, height: 630 },
                 article.thumbnail.blob.metadata.slice(:width, :height).symbolize_keys)
  end

  test '.just_fit_to_size?' do
    article = articles(:article4)

    image_resizer = ImageResizer.new(article.thumbnail)
    width, height = ImageResizer::OGP_SIZE
    image_resizer.fit_to!(width, height)

    assert image_resizer.just_fit_to_size?(width, height)
    assert_not image_resizer.just_fit_to_size?(width + 1, height)
    assert_not image_resizer.just_fit_to_size?(width, height + 1)
  end
end
