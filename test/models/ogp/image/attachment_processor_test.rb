# frozen_string_literal: true

require 'test_helper'

module Ogp
  module Image
    class AttachmentProcessorTest < ActiveSupport::TestCase
      test '.fit_to_size' do
        article = articles(:article4)

        AttachmentProcessor.fit_to_size(article.thumbnail)

        article.thumbnail.blob.analyze unless article.thumbnail.blob.analyzed?
        assert_equal({ width: 1200, height: 630 },
                     article.thumbnail.blob.metadata.slice(:width, :height).symbolize_keys)
      end

      test '.just_fit_to_size?' do
        assert AttachmentProcessor.just_fit_to_size?(width: 1200, height: 630)
        assert_not AttachmentProcessor.just_fit_to_size?(width: 1201, height: 630)
        assert_not AttachmentProcessor.just_fit_to_size?(width: 1200, height: 631)
      end

      test '.resize_option return 1200x when width magnification is grater than height magnification' do
        assert_equal({ resize: '1200x' }, AttachmentProcessor.resize_option(width: 500, height: 500))
        assert_equal({ resize: '1200x' }, AttachmentProcessor.resize_option(width: 500, height: 630))
        assert_equal({ resize: '1200x' }, AttachmentProcessor.resize_option(width: 1500, height: 1500))
      end

      test '.resize_option return x630 when height magnification is grater than width magnification' do
        assert_equal({ resize: 'x630' }, AttachmentProcessor.resize_option(width: 1000, height: 500))
        assert_equal({ resize: 'x630' }, AttachmentProcessor.resize_option(width: 1200, height: 500))
        assert_equal({ resize: 'x630' }, AttachmentProcessor.resize_option(width: 1500, height: 700))
      end
    end
  end
end
