# frozen_string_literal: true

class Products::NotRespondedController < ApplicationController
  def index
    @products = Product.not_responded_products.list.page(params[:page])
  end
end
