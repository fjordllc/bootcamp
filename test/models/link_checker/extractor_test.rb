# frozen_string_literal: true

require 'test_helper'

module LinkChecker
  class ExtractorTest < ActiveSupport::TestCase
    test '#extract_links' do
      extractor = LinkChecker::Extractor.new(<<~TEXT, 'apt', 'https://bootcamp.fjord.jp/1234')
                        aptとはdebianでソフトウェアをネットワークからインストールするコマンドです。
        #{'        '}
                        [TEST](/test)(/test2)
        #{'        '}
                        [missing](test)
                #{'        '}
                        - 参考
                            - [APT - Wikipedia](http://ja.wikipedia.org/wiki/APT)
                #{'        '}
                        ## Q&A
                #{'        '}
                        - Q. `$ apt-cache search vim` の検索結果が多すぎる
                        - A. [正規表現](https://ja.wikipedia.org/wiki/%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE) を使う。
                          - 完全一致: `$ apt-cache search ^vim$`
                          - 前方一致: `$ apt-cache search ^vim`
      TEXT

      expected = [
        LinkChecker::Link.new(
          'TEST',
          'https://bootcamp.fjord.jp/test',
          'apt',
          'https://bootcamp.fjord.jp/1234'
        ),
        LinkChecker::Link.new(
          'APT - Wikipedia',
          'http://ja.wikipedia.org/wiki/APT',
          'apt',
          'https://bootcamp.fjord.jp/1234'
        ),
        LinkChecker::Link.new(
          '正規表現',
          'https://ja.wikipedia.org/wiki/%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE',
          'apt',
          'https://bootcamp.fjord.jp/1234'
        )
      ]

      assert_equal expected, extractor.extract_links
    end
  end
end
