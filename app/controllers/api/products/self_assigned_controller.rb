# frozen_string_literal: true

class API::Products::SelfAssignedController < API::BaseController
  before_action :require_staff_login
  def index
    @products = Product.self_assigned_product(current_user.id).unchecked.list.page(params[:page])
  end
end
