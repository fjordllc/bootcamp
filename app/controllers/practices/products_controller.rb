class Practices::ProductsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @products = @practice.products.eager_load(:user, :comments).order(updated_at: :desc)
  end
end
