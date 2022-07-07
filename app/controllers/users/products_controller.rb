# frozen_string_literal: true

class Users::ProductsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_products

  def index; end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_products
    @products = if params[:target] == 'self_assigned'
                  user.products.where(checker_id: current_user.id).list.order_for_list
                else
                  user.products.list.order_for_list
                end
  end

  def user
    @user ||= User.find(params[:user_id])
  end
end
