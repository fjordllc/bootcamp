# frozen_string_literal: true

require "test_helper"

module LinkChecker
  class ClientTest < ActiveSupport::TestCase
    test ".request" do
      assert_equal 200, Client.request("http://example.com/")
      assert_equal 404, Client.request("https://fjord.jp/foo")
      assert_equal false, Client.request("http://foofoofoo.com/")
      assert_equal 200, Client.request("http://e-words.jp/w/単体テスト.html")
    end

    test "#request" do
      assert_equal 200, Client.new("http://example.com/").request
      assert_equal 404, Client.new("https://fjord.jp/foo").request
      assert_equal false, Client.new("http://foofoofoo.com/").request
      assert_equal 200, Client.new("http://e-words.jp/w/単体テスト.html").request
    end
  end
end
