# frozen_string_literal: true

class Users::ProductsController < ApplicationController
  before_action :set_user
  before_action :set_products

  def index
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_products
      if admin_login? || adviser_login? || current_user == @user
        @products = @user.products.eager_load(:user, :comments, :practice).order(updated_at: :desc)
      elsif @user.has_checked_product_of?(current_user.practices_with_checked_product)
        @products =
          Product
            .eager_load(:user, :comments, :practice)
            .where(id: @user.products.ids_of_common_checked_with(current_user))
            .order(updated_at: :desc)
      end
    end
end
