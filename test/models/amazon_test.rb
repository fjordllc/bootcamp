require 'test_helper'

class AmazonTest < ActiveSupport::TestCase
  PARTNER_TAG = ENV['AMAZON_PARTNER_TAG']

  setup do
    VCR.use_cassette("response") do
      @amazon = Amazon.new("B07JHQ9B5T")
    end
  end

  test "it should return image_url" do
    VCR.use_cassette("response") do
      assert_equal @amazon.image_url, "https://m.media-amazon.com/images/I/51EJg7Gnr0L._SL75_.jpg"
    end
  end

  test "it should return page_url" do
    VCR.use_cassette("response") do
      assert_equal @amazon.page_url, "https://www.amazon.co.jp/dp/B07JHQ9B5T?tag=#{PARTNER_TAG}&linkCode=ogi&th=1&psc=1"
    end
  end
end
