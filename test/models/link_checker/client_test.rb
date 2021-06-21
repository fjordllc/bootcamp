# frozen_string_literal: true

require 'test_helper'

module LinkChecker
  class ClientTest < ActiveSupport::TestCase
    test '.request' do
      VCR.use_cassette 'link_checker/client/request/example.com' do
        assert_equal 200, Client.request('http://example.com/')
      end
      VCR.use_cassette 'link_checker/client/request/fjord.jp' do
        assert_equal 404, Client.request('https://fjord.jp/foo')
      end
      VCR.use_cassette 'link_checker/client/request/foofoofoo.com' do
        assert_equal false, Client.request('http://foofoofoo.com/')
      end
      VCR.use_cassette 'link_checker/client/request/e-words.jp' do
        assert_equal 200, Client.request('https://e-words.jp/w/単体テスト.html')
      end
      VCR.use_cassette 'link_checker/client/request/developer.mozilla.org' do
        assert_equal 200, Client.request('https://developer.mozilla.org/ja/docs/Web/JavaScript#Tutorials')
      end
    end

    test '#request' do
      VCR.use_cassette 'link_checker/client/request/example.com' do
        assert_equal 200, Client.new('http://example.com/').request
      end
      VCR.use_cassette 'link_checker/client/request/fjord.jp' do
        assert_equal 404, Client.new('https://fjord.jp/foo').request
      end
      VCR.use_cassette 'link_checker/client/request/foofoofoo.com' do
        assert_equal false, Client.new('http://foofoofoo.com/').request
      end
      VCR.use_cassette 'link_checker/client/request/e-words.jp' do
        assert_equal 200, Client.new('https://e-words.jp/w/単体テスト.html').request
      end
      VCR.use_cassette 'link_checker/client/request/developer.mozilla.org' do
        assert_equal 200, Client.new('https://developer.mozilla.org/ja/docs/Web/JavaScript#Tutorials').request
      end
    end
  end
end
