# frozen_string_literal: true

class Api::ProductsController < Api::BaseController
  before_action :require_login_for_api, only: %i[index show]

  def index
    @company = Company.find(params[:company_id]) if params[:company_id]
    per = params[:per] || 50
    @products = Product
                .list
                .order_for_all_list
                .page(params[:page])
                .per(per)
    @products_grouped_by_elapsed_days = @products.group_by(&:elapsed_days)
    @products = @products.joins(:user).where(users: { company_id: params[:company_id] }) if params[:company_id]
    @products = @products.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def show
    @product = Product.find(params[:id])
  end
end
