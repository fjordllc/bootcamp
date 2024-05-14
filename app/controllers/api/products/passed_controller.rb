# frozen_string_literal: true

class API::Products::PassedController < API::BaseController
  def show
    products = Product
               .unassigned
               .unchecked
               .not_wip
    @passed4 = products.count { |product| product.elapsed_days == 4 }
    @passed5 = products.count { |product| product.elapsed_days == 5 }
    @over6 = products.count { |product| product.elapsed_days >= 6 }
  end
end
