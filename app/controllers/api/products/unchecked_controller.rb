# frozen_string_literal: true

class API::Products::UncheckedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @target = params[:target]
    @target = 'unchecked_all' unless target_allowlist.include?(@target)
    @products = case @target
                when 'unchecked_all'
                  Product.unchecked
                    .not_wip
                    .list
                    .order_for_not_wip_list
                    .page(params[:page])
                when 'unchecked_replied'
                  Product.unchecked_replied_products(current_user.id)
                    .unchecked
                    .not_wip
                    .list
                    .order_for_not_wip_list
                    .page(params[:page])
                end
    @latest_product_submitted_just_5days = @products.find { |product| product.elapsed_days == 5 }
    @latest_product_submitted_just_6days = @products.find { |product| product.elapsed_days == 6 }
    @latest_product_submitted_over_7days = @products.find { |product| product.elapsed_days >= 7 }
  end

  private
  
  def target_allowlist
    %w[unchecked_all unchecked_replied]
  end
end
