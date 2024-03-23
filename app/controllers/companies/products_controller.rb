# frozen_string_literal: true

class Companies::ProductsController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
    @products = Kaminari.paginate_array([]).page(params[:page]).per(5)
    @company.users.each do |user|
      user.products.each do |product|
        @products << product
      end
    end
  end
end
