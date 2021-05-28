# frozen_string_literal: true

class API::Products::NotificationToDiscordController < API::BaseController
  def index
    products = Product
               .not_responded_products
               .list
    @products_submitted_just_5days_count = products.count { |product| product.elapsed_days == 5 }
    @products_submitted_just_6days_count = products.count { |product| product.elapsed_days == 6 }
    @products_submitted_over_7days_count = products.count { |product| product.elapsed_days >= 7 }
  end
end
