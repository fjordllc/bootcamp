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
        "https://bootcamp.fjord.jp/practices/#{practices(:practice_3).id}"
      )

      @link_cpu = LinkChecker::Link.new(
        'CPUとは',
        'https://www.pc-master.jp/words/cpu.html',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice_3).id}"
      )

      @link_not_exist = LinkChecker::Link.new(
        '存在しないページ',
        'http://example.com/xxxxx',
        'Docsページ',
        "https://bootcamp.fjord.jp/pages/#{pages(:page_3).id}"
      )

      @link_example = LinkChecker::Link.new(
        'example',
        'http://example.com',
        'テスト',
        "https://bootcamp.fjord.jp/pages/#{pages(:page_2).id}"
      )

      @link_example = LinkChecker::Link.new(
        'example',
        'http://example.com',
        'テスト',
        "https://bootcamp.fjord.jp/pages/#{pages(:page_2).id}"
      )

      @link_mac = LinkChecker::Link.new(
        'Macの型番調べ辛い',
        'https://docs.komagata.org/4433',
        'PC性能の見方を知る',
        "https://bootcamp.fjord.jp/practices/#{practices(:practice_3).id}"
      )
    end

    test '#check' do
      checker = LinkChecker::Checker.new
      @link_hdd.response = false
      @link_not_exist.response = 404
      expected = [@link_hdd, @link_not_exist]
      assert_equal Set.new(expected), Set.new(checker.check)
    end

    test '#all_links' do
      checker = LinkChecker::Checker.new
      expected = [@link_example, @link_not_exist, @link_cpu, @link_hdd, @link_mac]
      assert_equal Set.new(expected), Set.new(checker.all_links)
    end
  end
end
