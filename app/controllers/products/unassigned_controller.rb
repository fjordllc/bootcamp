# frozen_string_literal: true

class Products::UnassignedController < ApplicationController
  before_action :require_staff_login

  def index
    @target = 'unassigned'
    @product_deadline_day = Product::PRODUCT_DEADLINE
    products = Product
               .unassigned
               .unchecked
               .not_wip
               .list
               .ascending_by_date_of_publishing_and_id

    @products = products
    @products_grouped_by_elapsed_days = Product.group_by_elapsed_days(products)
  end
end
