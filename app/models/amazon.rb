# frozen_string_literal: true

class Amazon
  def initialize(asin, access_key:, secret_key:, partner_tag:)
    @asin = asin
    @access_key = access_key
    @secret_key = secret_key
    @partner_tag = partner_tag
  end

  def image_url
    search_items.dig("ItemsResult", "Items")[0]["Images"]["Primary"]["Small"]["URL"]
  end

  def page_url
    search_items.dig("ItemsResult", "Items")[0]["DetailPageURL"]
  end

  def show_items
    puts search_items
  end

  private

    def request
      @request ||= Vacuum.new(marketplace: "JP",
        access_key: @access_key,
        secret_key: @secret_key,
        partner_tag: @partner_tag
      )
    end

    def search_items
      request.get_items(
        item_ids: [@asin],
        resources: ["Images.Primary.Small", "ItemInfo.Title", "ItemInfo.Features", "ParentASIN"]
      )
    end
end
