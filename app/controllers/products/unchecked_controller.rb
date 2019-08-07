# frozen_string_literal: true

class Products::UncheckedController < ApplicationController
  def index
    @products = Product.unchecked.list.page(params[:page])
  end
end
