# frozen_string_literal: true

class API::Products::PassedController < API::BaseController
  def show
    products = Product
               .unassigned
               .unchecked
               .not_wip
    product_deadline_day = ProductDeadline.first_or_create(alert_day: 4).alert_day
    @first_alert = products.count { |product| product.elapsed_days == product_deadline_day }
    @second_alert = products.count { |product| product.elapsed_days == product_deadline_day + 1 }
    @last_alert = products.count { |product| product.elapsed_days >= product_deadline_day + 2 }
  end
end
