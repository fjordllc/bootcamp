# frozen_string_literal: true

class API::Products::SelfAssignedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @target = params[:target]
    @target = 'self_assigned_all' unless target_allowlist.include?(@target)
    @products = case @target
                when 'self_assigned_all'
                  Product.self_assigned_product(current_user.id)
                         .unchecked
                         .list
                         .order_for_self_assigned_list
                         .page(params[:page])
                when 'self_assigned_no_replied'
                  Product.self_assigned_no_replied_products(current_user.id)
                         .unchecked
                         .list
                         .page(params[:page])
                end
  end

  private

  def target_allowlist
    %w[self_assigned_no_replied self_assigned_all]
  end
end
