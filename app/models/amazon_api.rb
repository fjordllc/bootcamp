# frozen_string_literal: true

class AmazonAPI
  attr_reader :asin, :request

  def initialize(asin)
    @asin = asin
    @request = Vacuum.new(marketplace: 'JP',
      access_key: ENV['AMAZON_ACCESS_KEY'],
      secret_key: ENV['AMAZON_SECRET_KEY'],
      partner_tag: ENV['AMAZON_PARTNER_TAG']
    )
    @response = api_response(@asin)
  end

  def image_url
    @response.dig('ItemsResult', 'Items')[0]['Images']['Primary']['Small']['URL']
  end

  def page_url
    @response.dig('ItemsResult', 'Items')[0]['DetailPageURL']
  end

  private

    def api_response(asin)
      @request.get_items(
        item_ids: [asin],
        resources: ['Images.Primary.Small', 'ItemInfo.Title', 'ItemInfo.Features', 'Offers.Summaries.HighestPrice', 'ParentASIN']
      )
    end
end
