# frozen_string_literal: true

class API::ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    render "show", formats: "json", handlers: "jbuilder"
  end
end
