class Practices::ProductsController < ApplicationController
  before_action :set_practice
  before_action :set_products

  def index
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_products
      if product_displayable?(practice: @practice)
        @products = @practice.products.eager_load(:user, :comments).order(updated_at: :desc)
      end
    end
end
