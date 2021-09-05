# frozen_string_literal: true

class API::Products::UncheckedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @products = Product.unchecked.not_wip.list.reorder_for_not_wip.page(params[:page])
  end
end
