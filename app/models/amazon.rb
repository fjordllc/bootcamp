# frozen_string_literal: true

class Amazon
  def self.fetch_api(practice)
    practice.reference_books.each do |book|
      res = book_search(book.asin)
      book.page_url = res.dig("ItemsResult", "Items")[0]["DetailPageURL"]
      book.image_url = res.dig("ItemsResult", "Items")[0]["Images"]["Primary"]["Small"]["URL"]
      book.save
    end
  end

  def self.book_search(asin)
    request = Vacuum.new(marketplace: 'JP',
      access_key: '',
      secret_key: '',
      partner_tag: ''
    )

    request.get_items(
      item_ids: [asin],
      resources: ["Images.Primary.Small", "ItemInfo.Title", "ItemInfo.Features", "Offers.Summaries.HighestPrice", "ParentASIN"]
    )
  end
end
