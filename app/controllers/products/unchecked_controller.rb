# frozen_string_literal: true

class Products::UncheckedController < ApplicationController
  def index
    @products = Product.unchecked.not_wip.list.page(params[:page])
  end
end
