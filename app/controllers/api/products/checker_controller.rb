# frozen_string_literal: true

class API::Products::CheckerController < API::BaseController
  before_action :require_mentor_login
  before_action :set_product, only: %i[update]

  def update
    if @product.save_checker(params[:current_user_id])
      render json: {
        checker_id: @product.checker_id,
        checker_name: @product.checker_name
      }
    else
      render status: :bad_request, json: { message: 'すでに他のメンターが担当者になっています。' }
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
