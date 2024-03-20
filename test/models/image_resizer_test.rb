# frozen_string_literal: true

require 'test_helper'

class ImageResizerTest < ActiveSupport::TestCase
  test '正常時ActiveStorage::VariantWithRecordインスタンスが返ること' do
    @user = users(:komagata)
    resizer = ImageResizer.new(@user.avatar)
    assert_instance_of ActiveStorage::VariantWithRecord, resizer.resize
  end
end
