# frozen_string_literal: true

class API::Products::UnassignedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @products = Product.unassigned.unchecked.not_wip.list.page(params[:page])
    @latest_product_submitted_just_5days = @products.find { |product| product.elapsed_days == 5 }
    @latest_product_submitted_just_6days = @products.find { |product| product.elapsed_days == 6 }
    @latest_product_submitted_over_7days = @products.find { |product| product.elapsed_days >= 7 }
  end
end
