# frozen_string_literal: true

class Products::WipController < ApplicationController
  def index
    @products = Product.wip.list.page(params[:page])
  end
end
