# frozen_string_literal: true

class API::Products::NotRespondedController < API::BaseController
  before_action :require_staff_login
  def index
    @products = Product.not_responded_products.list.page(params[:page])
  end
end
