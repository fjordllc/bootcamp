# frozen_string_literal: true

class Products::SelfAssignedController < ApplicationController
  before_action :require_staff_login
  before_action :set_target
  def index
    @target = params[:target].presence_in(target_allowlist) || 'self_assigned_all'
    @products = build_self_assigned_products
                .unchecked
                .list
                .page(params[:page])
                .per(50)
  end

  private

  def target_allowlist
    %w[self_assigned_no_replied self_assigned_all]
  end

  def build_self_assigned_products
    base_scope = Product.unhibernated_user_products

    case @target
    when 'self_assigned_all'
      base_scope.self_assigned_product(current_user.id)
                .order_for_self_assigned_list
    when 'self_assigned_no_replied'
      base_scope.self_assigned_no_replied_products(current_user.id)
    end
  end

  def set_target
    @target = 'self_assigned'
  end
end
