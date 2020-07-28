require 'test_helper'

class AmazonApiTest < ActiveSupport::TestCase
  def setup
    @amazon_api = AmazonAPI.new("B07JHQ9B5T")
  end

  def test_has_asin
    assert_equal @amazon_api.asin, "B07JHQ9B5T"
  end

  def test_has_request
    assert @amazon_api.request
  end

  def test_image_url
    image_url = @amazon_api.image_url
    assert_equal image_url, "https://m.media-amazon.com/images/I/51EJg7Gnr0L._SL75_.jpg"
  end

  def test_page_url
    page_url = @amazon_api.page_url
    assert_equal page_url, "https://www.amazon.co.jp/dp/B07JHQ9B5T?tag=twitter0f1-22&linkCode=ogi&th=1&psc=1"
  end
end
