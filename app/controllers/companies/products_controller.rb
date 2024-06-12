# frozen_string_literal: true

class Companies::ProductsController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
    products = @company.users.flat_map(&:products)
    @products = Kaminari.paginate_array(products.sort).page(params[:page]).per(50)
  end
end
