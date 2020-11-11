# frozen_string_literal: true

class Products::NotRespondedController < ApplicationController
  before_action :require_staff_login
  def index
    @products = Product.not_responded_products.list.page(params[:page])
  end
end
