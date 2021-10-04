# frozen_string_literal: true

class CurrentUser::ProductsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_products

  def index; end

  private

  def set_user
    @user = current_user
  end

  def set_products
    @products = user.products.list.order_for_list
  end

  def user
    @user ||= current_user
  end
end
