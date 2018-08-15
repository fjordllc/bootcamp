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
      if product_displayable?(user: @user)
        @products = @user.products.eager_load(:user, :comments).order(updated_at: :desc)
      end
    end
end
