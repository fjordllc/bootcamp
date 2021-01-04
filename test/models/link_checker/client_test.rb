# frozen_string_literal: true

require 'test_helper'

module LinkChecker
  class ClientTest < ActiveSupport::TestCase
    test '.request' do
      assert_equal 200, Client.request('http://example.com/')
      assert_equal 404, Client.request('https://fjord.jp/foo')
      assert_equal false, Client.request('http://foofoofoo.com/')
      assert_equal 200, Client.request('https://e-words.jp/w/単体テスト.html')
      assert_equal 200, Client.request('https://developer.mozilla.org/ja/docs/Web/JavaScript#Tutorials')
    end

    test '#request' do
      assert_equal 200, Client.new('http://example.com/').request
      assert_equal 404, Client.new('https://fjord.jp/foo').request
      assert_equal false, Client.new('http://foofoofoo.com/').request
      assert_equal 200, Client.new('https://e-words.jp/w/単体テスト.html').request
      assert_equal 200, Client.new('https://developer.mozilla.org/ja/docs/Web/JavaScript#Tutorials').request
    end
  end
end
