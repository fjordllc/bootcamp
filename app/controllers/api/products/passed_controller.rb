# frozen_string_literal: true

class Api::Products::PassedController < Api::BaseController
  def show
    products = Product
               .unassigned
               .unchecked
               .not_wip
    @product_deadline_day = Product::PRODUCT_DEADLINE
    @first_alert = products.count { |product| product.elapsed_days == @product_deadline_day }
    @second_alert = products.count { |product| product.elapsed_days == @product_deadline_day + 1 }
    @last_alert = products.count { |product| product.elapsed_days >= @product_deadline_day + 2 }
  end
end
