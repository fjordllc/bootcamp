# frozen_string_literal: true

class API::Products::UnassignedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @products = Product
                .unassigned
                .unchecked
                .not_wip
                .list
                .order_for_not_wip_list
    @latest_product_submitted_just_5days = @products.find { |product| product.elapsed_days == 5 }
    @latest_product_submitted_just_6days = @products.find { |product| product.elapsed_days == 6 }
    @latest_product_submitted_over_7days = @products.find { |product| product.elapsed_days >= 7 }
    render 'index.json'
  end

  def text
    products = Product
               .unassigned
               .unchecked
               .not_wip
               .five_days_and_earlier
    @passed5 = products.count { |product| product.elapsed_days == 5 }
    @passed6 = products.count { |product| product.elapsed_days == 6 }
    @over7 = products.count { |product| product.elapsed_days >= 7 }
    render 'text.txt'
  end
end
