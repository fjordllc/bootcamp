# frozen_string_literal: true

class API::ProductsController < API::BaseController
  def show
    @product = Product.find(params[:id])
    @check = @product.checks&.last
    @checked_user = @check&.user&.login_name
    @check_craeted_at = @check.present? ? I18n.l(@check.created_at.to_date, format: :short) : nil
  end
end
