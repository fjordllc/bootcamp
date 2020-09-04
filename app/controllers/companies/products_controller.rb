# frozen_string_literal: true

class Companies::ProductsController < ApplicationController
  before_action :require_login
  before_action :set_company
  before_action :set_products

  def index
  end

  private
    def set_company
      @company = Company.find(params[:company_id])
    end

    def set_products
      @products = Product.includes(:user).where(users: { company: company }).list.page(params[:page])
    end

    def company
      @company ||= Company.find(params[:company_id])
    end
end
