# frozen_string_literal: true

require 'test_helper'

module Link
  class ClientTest < ActiveSupport::TestCase
    test '.request' do
      VCR.use_cassette 'link/client/request/example.com' do
        response = Client.request('http://example.com/')
        assert_equal '200', response.code
        assert_match '<h1>Example Domain</h1>', response.body
      end
      VCR.use_cassette 'link/client/request/developer.mozilla.org' do
        response = Client.request('https://developer.mozilla.org/ja/docs/Web/JavaScript')
        assert_equal '200', response.code
        assert_match '<h1>JavaScript</h1>', response.body
      end
      VCR.use_cassette 'link/client/request/not-found.fjord.jp' do
        assert_equal '404', Client.request('https://lokka.jp/foo').code
      end
      VCR.use_cassette 'link/client/request/foobarbuzzzzzzzzzzzzz.com' do
        assert_not Client.request('http://foobarbuzzzzzzzzzzzzz.com/')
      end
    end
    test '#request' do
      VCR.use_cassette 'link/client/request/example.com' do
        response = Client.new('http://example.com/').request
        assert_equal '200', response.code
        assert_match '<h1>Example Domain</h1>', response.body
      end
      VCR.use_cassette 'link/client/request/developer.mozilla.org' do
        response = Client.new('https://developer.mozilla.org/ja/docs/Web/JavaScript').request
        assert_equal '200', response.code
        assert_match '<h1>JavaScript</h1>', response.body
      end
      VCR.use_cassette 'link/client/request/not-found.fjord.jp' do
        assert_equal '404', Client.new('https://lokka.jp/foo').request.code
      end
      VCR.use_cassette 'link/client/request/foobarbuzzzzzzzzzzzzz.com' do
        assert_not Client.new('http://foobarbuzzzzzzzzzzzzz.com/').request
      end
    end
  end
end
