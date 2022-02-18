# frozen_string_literal: true

require 'test_helper'

module LinkChecker
  class CheckerTest < ActiveSupport::TestCase
    setup do
      @link_hdd = Link.new(
        'HDDが分かる',
        'http://homepage2.nifty.com/kamurai/HDD.htm',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice3).id}"
      )

      @link_cpu = Link.new(
        'CPUとは',
        'https://www.pc-master.jp/words/cpu.html',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice3).id}"
      )

      @link_not_exist = Link.new(
        '存在しないページ',
        'http://example.com/xxxxx',
        'Docsページ',
        "https://bootcamp.fjord.jp/pages/#{pages(:page3).id}"
      )

      @link_example = Link.new(
        'example',
        'http://example.com',
        'テスト',
        "https://bootcamp.fjord.jp/pages/#{pages(:page2).id}"
      )

      @link_mac = Link.new(
        'Macの型番調べ辛い',
        'https://docs.komagata.org/4433',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice3).id}"
      )
    end

    test '.check_response' do
      VCR.use_cassette 'link_checker/checker/check_response' do
        expected = [
          LinkChecker::Link.new(
            'HDDが分かる',
            'http://homepage2.nifty.com/kamurai/HDD.htm',
            'PC性能の見方を知る',
            "https://bootcamp.fjord.jp/practices/#{practices(:practice3).id}",
            false
          ),
          LinkChecker::Link.new(
            '存在しないページ',
            'http://example.com/xxxxx',
            'Docsページ',
            "https://bootcamp.fjord.jp/pages/#{pages(:page3).id}",
            404
          ),
          LinkChecker::Link.new(
            'example',
            'http://example.com',
            'テスト',
            "https://bootcamp.fjord.jp/pages/#{pages(:page2).id}",
            200
          )
        ]

        assert_equal expected, Checker.check_response([@link_hdd, @link_not_exist, @link_example])
      end
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

    test '.summary' do
      expected = <<~TEXT
        リンク切れがありました。
        - <http://example.com/xxxxx | 存在しないページ> in: <https://bootcamp.fjord.jp/pages/380151014 | Docsページ>
        - <http://example.com | example> in: <https://bootcamp.fjord.jp/pages/565154931 | テスト>
        - <http://homepage2.nifty.com/kamurai/HDD.htm | HDDが分かる> in: <https://bootcamp.fjord.jp/practices/1019809339 | PC性能の見方を知る>
        - <https://docs.komagata.org/4433 | Macの型番調べ辛い> in: <https://bootcamp.fjord.jp/practices/1019809339 | PC性能の見方を知る>
        - <https://www.pc-master.jp/words/cpu.html | CPUとは> in: <https://bootcamp.fjord.jp/practices/1019809339 | PC性能の見方を知る>
      TEXT

      assert_equal expected.chomp, Checker.summary([@link_hdd, @link_cpu, @link_not_exist, @link_example, @link_mac])
    end
  end
end
