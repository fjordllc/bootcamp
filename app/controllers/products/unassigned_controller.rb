# frozen_string_literal: true

class Products::UnassignedController < ApplicationController
  before_action :require_staff_login

  def index
    @target = 'unassigned'
    @product_deadline_day = Product::PRODUCT_DEADLINE
    @products = Product.unassigned
                       .list
                       .order_for_all_list
                       .page(params[:page])
                       .per(50)
  end
end
