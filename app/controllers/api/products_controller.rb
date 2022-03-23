# frozen_string_literal: true

class API::ProductsController < API::BaseController
  before_action :require_staff_login_for_api, only: :index

  def index
    @products = Product
                .list
                .order_for_not_wip_list
                .page(params[:page])
  end
end
