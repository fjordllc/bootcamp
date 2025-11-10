# frozen_string_literal: true

class Api::Products::UnassignedController < Api::BaseController
  before_action :require_staff_login_for_api
  def index
    @products = Product
                .unassigned
                .unchecked
                .not_wip
                .list
                .ascending_by_date_of_publishing_and_id
    @products_grouped_by_elapsed_days = @products.group_by(&:elapsed_days)
  end

  def counts
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
