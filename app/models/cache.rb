class Cache
  class << self
    def unchecked_report_count
      Rails.cache.fetch "unchecked_report_count" do
        Report.unchecked.not_wip.count
      end
    end

    def delete_unchecked_report_count
      Rails.cache.fetch "unchecked_report_count"
    end

    def unchecked_product_count
      Rails.cache.fetch "unchecked_product_count" do
        Product.unchecked.not_wip.count
      end
    end

    def delete_unchecked_product_count
      Rails.cache.delete "unchecked_product_count"
    end

    def not_responded_product_count
      Rails.cache.fetch "not_responded_product_count" do
        Product.not_responded_products.count
      end
    end

    def delete_not_responded_product_count
      Rails.cache.delete "not_responded_product_count"
    end
  end
end
