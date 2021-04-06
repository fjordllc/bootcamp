# frozen_string_literal: true

class API::Products::NotificationToDiscordController < API::BaseController
  def index
    products = Product
                .not_responded_products
                .list
                .reorder_for_not_responded_products
                .page(params[:page])
    @products_submitted_just_5days_count = 0
    @products_submitted_just_6days_count = 0
    @products_submitted_over_7days_count = 0
    products.each do |product|
      if product.submitted_just_specific_days(5)
        @products_submitted_just_5days_count += 1
      elsif product.submitted_just_specific_days(6)
        @products_submitted_just_6days_count += 1
      elsif product.submitted_over_specific_days(7)
        @products_submitted_over_7days_count += 1
      end
    end
  end
end
