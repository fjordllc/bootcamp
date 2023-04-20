# frozen_string_literal: true

require 'test_helper'

module Ogp
  class ImageTest < ActiveSupport::TestCase
    module Dummy
      extend Ogp::Image
    end

    test '.fit_to_size_option' do
      expected = { resize: '1200x', gravity: :center, crop: '1200x630+0+0!' }
      assert_equal expected.to_a, Dummy.fit_to_size_option(width: 500, height: 500).to_a
    end

    test '.fit?' do
      assert Dummy.fit?(width: 1200, height: 630)
      assert_not Dummy.fit?(width: 1201, height: 630)
      assert_not Dummy.fit?(width: 1200, height: 631)
    end

    test '.resize_option return 1200x when width magnification is grater than height magnification' do
      assert_equal({ resize: '1200x' }, Dummy.resize_option(width: 500, height: 500))
      assert_equal({ resize: '1200x' }, Dummy.resize_option(width: 500, height: 630))
      assert_equal({ resize: '1200x' }, Dummy.resize_option(width: 1500, height: 1500))
    end

    test '.resize_option return x630 when height magnification is grater than width magnification' do
      assert_equal({ resize: 'x630' }, Dummy.resize_option(width: 1000, height: 500))
      assert_equal({ resize: 'x630' }, Dummy.resize_option(width: 1200, height: 500))
      assert_equal({ resize: 'x630' }, Dummy.resize_option(width: 1500, height: 700))
    end
  end
end
