# frozen_string_literal: true

class Products::CheckerAssignmentsController < ApplicationController
  before_action :find_product

  def create
    @product.update!(checker: current_user)
    redirect_back(fallback_location: @product, notice: '担当になりました。')
  end

  def destroy
    @product.update!(checker: nil)
    redirect_back(fallback_location: @product, notice: '担当から外れました。')
  end

  private

  def find_product
    product_id = params[:product_id] || params[:id]
    @product = Product.find(product_id)
  end
end