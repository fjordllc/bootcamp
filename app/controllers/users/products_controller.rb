# frozen_string_literal: true

class Users::ProductsController < ApplicationController
  before_action :set_user
  before_action :set_products

  def index
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_products
      @products = user.products.list
    end

    def user
      @user ||= User.find(params[:user_id])
    end
end
