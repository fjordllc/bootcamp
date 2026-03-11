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
    @products_grouped_by_elapsed_days = group_and_merge_by_elapsed_days(products)
  end

  private

  def group_and_merge_by_elapsed_days(products)
    reply_deadline_days = @product_deadline_day + 2
    grouped = products.group_by do |product|
      product.elapsed_days >= reply_deadline_days ? reply_deadline_days : product.elapsed_days
    end
    grouped.transform_values { |v| v }
  end
end
