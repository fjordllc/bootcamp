# frozen_string_literal: true

require "test_helper"

class AmazonTest < ActiveSupport::TestCase
  setup do
    json = File.read("#{Rails.root}/test/fixtures/files/mock_bodies/amazon.json")
    stub_request(:post, 'https://webservices.amazon.co.jp/paapi5/getitems')
      .to_return(
        status: 200,
        body: json,
      )
    @amazon = Amazon.new('B07JHQ9B5T', access_key: 'mock_access_key', secret_key: 'mock_secret_key', partner_tag: 'mock_partner_tag')
  end

  test 'should return page_url' do
    assert_equal @amazon.page_url, "https://www.amazon.co.jp/dp/B07JHQ9B5T?tag=mock_partner_tag&linkCode=ogi&th=1&psc=1"
  end

  test 'should return image_url' do
    assert_equal @amazon.image_url, 'https://m.media-amazon.com/images/I/51EJg7Gnr0L._SL75_.jpg'
  end
end
