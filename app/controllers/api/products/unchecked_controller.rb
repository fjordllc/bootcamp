# frozen_string_literal: true

class API::Products::UncheckedController < API::BaseController
  before_action :require_staff_login
  def index
    @products = Product.unchecked.not_wip.list.page(params[:page])
  end
end
