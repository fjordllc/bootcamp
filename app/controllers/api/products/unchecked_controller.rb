# frozen_string_literal: true

class API::Products::UncheckedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @products = Product
                .unchecked
                .not_wip
                .list
                .order_for_not_wip_list
                .page(params[:page])
  end
end
