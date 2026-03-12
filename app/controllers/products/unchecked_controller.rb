# frozen_string_literal: true

class Products::UncheckedController < ApplicationController
  before_action :require_staff_login

  def index
    @checker_id = params[:checker_id]

    @target = params[:target]
    @target = 'unchecked_all' unless target_allowlist.include?(@target)

    @products = build_products_scope
    @products = @products.where(checker_id: @checker_id) if @checker_id.present?
    @products = @products.page(params[:page]).per(50)
  end

  private

  def build_products_scope
    case @target
    when 'unchecked_all'
      Product.unhibernated_user_products
             .unchecked
             .not_wip
             .list
             .ascending_by_date_of_publishing_and_id
    when 'unchecked_no_replied'
      UncheckedNoRepliedProductsQuery.new.call
                                     .unhibernated_user_products
                                     .not_wip
                                     .list
                                     .ascending_by_date_of_publishing_and_id
    end
  end

  def target_allowlist
    %w[unchecked_all unchecked_no_replied]
  end
end
