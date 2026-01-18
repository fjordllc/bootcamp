# frozen_string_literal: true

require 'test_helper'

module SmartSearch
  class TextExtractorTest < ActiveSupport::TestCase
    test 'extracts text from Practice' do
      practice = practices(:practice1)
      text = TextExtractor.extract(practice)
      assert_includes text, practice.title
    end
  end
end
