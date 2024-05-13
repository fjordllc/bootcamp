# frozen_string_literal: true

class API::Products::UnassignedController < API::BaseController
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
    @passed4 = products.count { |product| product.elapsed_days == 4 }
    @passed5 = products.count { |product| product.elapsed_days == 5 }
    @over6 = products.count { |product| product.elapsed_days >= 6 }
  end
end
