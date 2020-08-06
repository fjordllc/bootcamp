# frozen_string_literal: true
ACCESS_KEY = ENV["AMAZON_ACCESS_KEY"]
SECRET_KEY = ENV["AMAZON_SECRET_KEY"]
PARTNER_TAG = ENV["AMAZON_PARTNER_TAG"]

class Amazon

  def initialize(asin, access_key:, secret_key:, partner_tag:)
    @asin = asin
    @response = response(@asin)
    @access_key = access_key
    @secret_key = secret_key
    @partner_tag = partner_tag
  end

  def image_url
    @response.dig("ItemsResult", "Items")[0]["Images"]["Primary"]["Small"]["URL"]
  end

  def page_url
    @response.dig("ItemsResult", "Items")[0]["DetailPageURL"]
  end

  private

    def request
      Vacuum.new(marketplace: "JP",
        access_key: ACCESS_KEY,
        secret_key: SECRET_KEY,
        partner_tag: PARTNER_TAG
      )
    end

    def response(asin)
      request.get_items(
        item_ids: [asin],
        resources: ["Images.Primary.Small", "ItemInfo.Title", "ItemInfo.Features", "Offers.Summaries.HighestPrice", "ParentASIN"]
      )
    end
end
