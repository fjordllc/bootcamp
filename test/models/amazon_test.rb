# frozen_string_literal: true

require "test_helper"

class AmazonTest < ActiveSupport::TestCase
  setup do
    stub_amazon!
    @amazon = Amazon.new("B07JHQ9B5T", access_key: "mock_access_key", secret_key: "mock_secret_key", partner_tag: "mock_partner_tag")
  end

  test "should return page_url" do
    assert_equal "https://www.amazon.co.jp/dp/B07JHQ9B5T?tag=mock_partner_tag&linkCode=ogi&th=1&psc=1", @amazon.page_url
  end

  test "should return image_url" do
    assert_equal "https://m.media-amazon.com/images/I/51EJg7Gnr0L._SL75_.jpg", @amazon.image_url
  end
end
