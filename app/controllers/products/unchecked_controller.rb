# frozen_string_literal: true

class Products::UncheckedController < ApplicationController
  before_action :require_staff_login
  def index
    @products = Product.unchecked.not_wip.list.page(params[:page])
  end
end
