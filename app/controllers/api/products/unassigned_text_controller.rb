# frozen_string_literal: true

class API::Products::UnassignedTextController < API::BaseController
  def show
    @products = Product
                .unassigned
                .unchecked
                .not_wip
                .list
                .order_for_not_wip_list
    @passed5 = @products.count { |product| product.elapsed_days == 5 }
    @passed6 = @products.count { |product| product.elapsed_days == 6 }
    @over7 = @products.count { |product| product.elapsed_days >= 7 }
  end
end
