# frozen_string_literal: true

require 'test_helper'
require 'link_checker/extractor'

module LinkChecker
  class CheckerTest < ActiveSupport::TestCase
    setup do
      @link_hdd = LinkChecker::Link.new(
        'HDDが分かる',
        'http://homepage2.nifty.com/kamurai/HDD.htm',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice3).id}"
      )

      @link_cpu = LinkChecker::Link.new(
        'CPUとは',
        'https://www.pc-master.jp/words/cpu.html',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice3).id}"
      )

      @link_not_exist = LinkChecker::Link.new(
        '存在しないページ',
        'http://example.com/xxxxx',
        'Docsページ',
        "https://bootcamp.fjord.jp/pages/#{pages(:page3).id}"
      )

      @link_example = LinkChecker::Link.new(
        'example',
        'http://example.com',
        'テスト',
        "https://bootcamp.fjord.jp/pages/#{pages(:page2).id}"
      )

      @link_example = LinkChecker::Link.new(
        'example',
        'http://example.com',
        'テスト',
        "https://bootcamp.fjord.jp/pages/#{pages(:page2).id}"
      )

      @link_mac = LinkChecker::Link.new(
        'Macの型番調べ辛い',
        'https://docs.komagata.org/4433',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice3).id}"
      )
    end

    test '.valid_url? returns true with a valid url' do
      assert Checker.valid_url?('http://example.com')
      assert Checker.valid_url?('https://ja.wikipedia.org/wiki/あ')
    end

    test '.valid_url? returns false with an invalid url' do
      assert_not Checker.valid_url?('http://invalid space exists')
    end

    test '.denied_host? returns true when an url contains a denied host' do
      assert Checker.denied_host?('https://codepen.io/')
      assert Checker.denied_host?('https://www.amazon.co.jp')
    end

    test '.denied_host? returns false when an url doesn\'t contain a denied host' do
      assert_not Checker.denied_host?('http://example.com')
    end

    test '#check' do
      VCR.use_cassette 'link_checker/checker/check' do
        links = [@link_hdd, @link_cpu, @link_not_exist, @link_example, @link_mac]
        checker = Checker.new(links)

        @link_hdd.response = false
        @link_not_exist.response = 404
        expected = [@link_hdd, @link_not_exist]

        assert_equal expected, checker.check
      end
    end
  end
end
