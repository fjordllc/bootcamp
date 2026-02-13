# frozen_string_literal: true

class Products::UncheckedController < ApplicationController
  before_action :require_staff_login

  def index
    @checker_id = params[:checker_id]

    @target = params[:target]
    @target = 'unchecked_all' unless target_allowlist.include?(@target)

    products_scope = Product.unchecked.list
    products_scope = products_scope.where(checker_id: @checker_id) if @checker_id.present?

    @products = products_scope.order_for_all_list
                              .page(params[:page])
                              .per(50)
  end

  private

  def target_allowlist
    %w[unchecked_all unchecked_no_replied]
  end
end
