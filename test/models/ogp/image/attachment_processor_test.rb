# frozen_string_literal: true

require 'test_helper'

module Ogp
  module Image
    class AttachmentProcessorTest < ActiveSupport::TestCase
      test '.fit_to_size' do
        article = articles(:article4)

        AttachmentProcessor.fit_to_size(article.thumbnail)

        article.thumbnail.blob.analyze unless article.thumbnail.blob.analyzed?
        assert_equal({ width: WIDTH, height: HEIGHT },
                     article.thumbnail.blob.metadata.slice(:width, :height).symbolize_keys)
      end
    end
  end
end
