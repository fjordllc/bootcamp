# frozen_string_literal: true

require 'test_helper'

module LinkChecker
  class ExtractorTest < ActiveSupport::TestCase
    test '#extract_links from a practice' do
      page = pages(:page8)
      extractor = LinkChecker::Extractor.new(page)

      expected = [
        LinkChecker::Link.new(
          'TEST',
          'https://bootcamp.fjord.jp/test',
          'apt',
          "https://bootcamp.fjord.jp#{page.path}"
        ),
        LinkChecker::Link.new(
          'APT - Wikipedia',
          'http://ja.wikipedia.org/wiki/APT',
          'apt',
          "https://bootcamp.fjord.jp#{page.path}"
        ),
        LinkChecker::Link.new(
          '正規表現',
          'https://ja.wikipedia.org/wiki/%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE',
          'apt',
          "https://bootcamp.fjord.jp#{page.path}"
        )
      ]

      assert_equal expected, extractor.extract_links
    end

    test '#extract_links from a page' do
      practice = practices(:practice3)
      extractor = LinkChecker::Extractor.new(practice)

      expected = [
        LinkChecker::Link.new(
          'CPUとは',
          'https://www.pc-master.jp/words/cpu.html',
          'PC性能の見方を知る',
          "https://bootcamp.fjord.jp#{practice.path}"
        ),
        LinkChecker::Link.new(
          'HDDが分かる',
          'http://homepage2.nifty.com/kamurai/HDD.htm',
          'PC性能の見方を知る',
          "https://bootcamp.fjord.jp#{practice.path}"
        ),
        LinkChecker::Link.new(
          'Macの型番調べ辛い',
          'https://docs.komagata.org/4433',
          'PC性能の見方を知る',
          "https://bootcamp.fjord.jp#{practice.path}"
        )
      ]

      assert_equal expected, extractor.extract_links
    end

    test '::MARKDOWN_LINK_REGEXP' do
      actual = pages(:page8).body.scan(Extractor::MARKDOWN_LINK_REGEXP).map { |match| match.take(2) }
      expected = [
        ['TEST', '/test'],
        %w[missing test],
        ['APT - Wikipedia', 'http://ja.wikipedia.org/wiki/APT'],
        ['正規表現', 'https://ja.wikipedia.org/wiki/%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE']
      ]

      assert_equal expected, actual
    end

    test '::MARKDOWN_LINK_REGEXP matches exactly an url that ends with closing parentheses' do
      actual = '[末尾が閉じ括弧の URL のリンク](https://example.com/(hoge))'.scan(Extractor::MARKDOWN_LINK_REGEXP).map { |match| match.take(2) }
      expected = [['末尾が閉じ括弧の URL のリンク', 'https://example.com/(hoge)']]

      assert_equal expected, actual
    end
  end
end
