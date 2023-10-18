# frozen_string_literal: true

require 'test_helper'

class ImageResizerTransformationTest < ActiveSupport::TestCase
  setup do
    @image_resizer_transformation = ImageResizerTransformation.new
    @width = 1200
    @height = 630
  end

  test '.fit_to' do
    assert_equal({ resize: "#{@width}x", gravity: :center, crop: "#{@width}x#{@height}+0+0!" },
                 @image_resizer_transformation.fit_to(500, 500, @width, @height))
  end

  test '.resize return 1200x when width magnification is grater than height magnification' do
    assert_equal({ resize: "#{@width}x" }, @image_resizer_transformation.resize(500, 500, @width, @height))
    assert_equal({ resize: "#{@width}x" }, @image_resizer_transformation.resize(500, 630, @width, @height))
    assert_equal({ resize: "#{@width}x" }, @image_resizer_transformation.resize(1500, 1500, @width, @height))
  end

  test '.resize return x630 when height magnification is grater than width magnification' do
    assert_equal({ resize: "x#{@height}" }, @image_resizer_transformation.resize(1000, 500, @width, @height))
    assert_equal({ resize: "x#{@height}" }, @image_resizer_transformation.resize(1200, 500, @width, @height))
    assert_equal({ resize: "x#{@height}" }, @image_resizer_transformation.resize(1500, 700, @width, @height))
  end

  test '.center_crop' do
    assert_equal({ gravity: :center, crop: "#{@width}x#{@height}+0+0!" },
                 @image_resizer_transformation.center_crop(@width, @height))
  end
end
