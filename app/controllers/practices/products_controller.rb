# frozen_string_literal: true

class Practices::ProductsController < ApplicationController
  before_action :set_practice
  before_action :set_products

  def index
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_products
      @products = practice.products.eager_load(:user, :comments).order(updated_at: :desc)
    end

    def practice
      @practice ||= Practice.find(params[:practice_id])
    end
end
