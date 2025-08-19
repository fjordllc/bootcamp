# frozen_string_literal: true

class Products::UnassignedController < ApplicationController
  before_action :require_staff_login
  before_action :set_target
  def index
    @product_deadline_day = Product::PRODUCT_DEADLINE
    @products = Product.unassigned
                       .list
                       .order_for_all_list
                       .page(params[:page])
                       .per(50)
  end

  private

  def set_target
    @target = 'unassigned'
  end
end
