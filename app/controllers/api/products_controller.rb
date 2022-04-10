# frozen_string_literal: true

class API::ProductsController < API::BaseController
  before_action :require_staff_login_for_api, only: :index

  def index
    @products = Product
                .list
                .ascending_by_date_of_publishing_and_id
                .page(params[:page])
    @products_grouped_by_elapsed_days = @products
                              .group_by { |product| product.elapsed_days >= 7 ? 7 : product.elapsed_days }
  end
end
