# frozen_string_literal: true

class API::Products::PassedController < API::BaseController
  def show
    products = Product
               .list
               .ascending_by_date_of_publishing_and_id
    @passed5 = products.count { |product| product.elapsed_days == 5 }
    @passed6 = products.count { |product| product.elapsed_days == 6 }
    @over7 = products.count { |product| product.elapsed_days >= 7 }
  end
end
