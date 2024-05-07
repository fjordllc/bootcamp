# frozen_string_literal: true

class API::Products::PassedController < API::BaseController
  def show
    products = Product
               .list
               .ascending_by_date_of_publishing_and_id
    @passed4 = products.count { |product| product.elapsed_days == 4 }
    @passed5 = products.count { |product| product.elapsed_days == 5 }
    @over6 = products.count { |product| product.elapsed_days >= 6 }
  end
end
