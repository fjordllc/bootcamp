# frozen_string_literal: true

class API::Products::NotRespondedController < API::BaseController
  before_action :require_staff_login
  def index
    @products = Product
                .not_responded_products
                .list
                .reorder_for_not_responded_products
                .page(params[:page])
    @latest_product_submitted_just_5days = @products.find { |product| product.elapsed_days == 5 }
    @latest_product_submitted_just_6days = @products.find { |product| product.elapsed_days == 6 }
    @latest_product_submitted_over_7days = @products.find { |product| product.elapsed_days >= 7 }
  end
end
