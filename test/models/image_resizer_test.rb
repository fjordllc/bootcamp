# frozen_string_literal: true

require 'test_helper'

class ImageResizerTest < ActiveSupport::TestCase
  setup do
    user = users(:komagata)
    @image = user.avatar
  end

  test '正常時ActiveStorage::VariantWithRecordインスタンスが返ること' do
    resizer = ImageResizer.new(@image)
    assert_instance_of ActiveStorage::VariantWithRecord, resizer.resize
  end

  test 'resize_to_fitとcropで切り抜くこと' do
    image_resizer = ImageResizer.new(@image, resize_side: { width: 120, height: 120 })
    format_option_keys = image_resizer.resize.variation.transformations.keys

    assert_includes format_option_keys, :resize_to_fit
    assert_includes format_option_keys, :crop
  end

  test 'optionsを使って引数を渡せること' do
    options = { autorot: true, saver: { strip: true, quality: 60 } }
    image_resizer = ImageResizer.new(@image, options:)

    format_option_keys = image_resizer.resize.variation.transformations.keys
    assert_includes format_option_keys, :autorot
    assert_includes format_option_keys, :saver
  end
end
