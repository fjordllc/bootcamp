# frozen_string_literal: true

require 'test_helper'

module LinkChecker
  class ExtractorTest < ActiveSupport::TestCase
    test '#extract_links' do
      page = pages(:page8)
      extractor = LinkChecker::Extractor.new(page.body, page.title, "https://bootcamp.fjord.jp/#{page.path}")

      expected = [
        LinkChecker::Link.new(
          'TEST',
          'https://bootcamp.fjord.jp/test',
          'apt',
          "https://bootcamp.fjord.jp/#{page.path}"
        ),
        LinkChecker::Link.new(
          'APT - Wikipedia',
          'http://ja.wikipedia.org/wiki/APT',
          'apt',
          "https://bootcamp.fjord.jp/#{page.path}"
        ),
        LinkChecker::Link.new(
          '正規表現',
          'https://ja.wikipedia.org/wiki/%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE',
          'apt',
          "https://bootcamp.fjord.jp/#{page.path}"
        )
      ]

      assert_equal expected, extractor.extract_links
    end
  end
end
