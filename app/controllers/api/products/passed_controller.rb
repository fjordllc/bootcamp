# frozen_string_literal: true

class API::Products::PassedController < API::BaseController
  def show
    products = Product
               .list
               .order_for_not_wip_list
    @passed5 = products.count { |product| product.elapsed_days == 5 }
    @passed6 = products.count { |product| product.elapsed_days == 6 }
    @over7 = products.count { |product| product.elapsed_days >= 7 }
  end
end
