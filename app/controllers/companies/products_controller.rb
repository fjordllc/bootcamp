# frozen_string_literal: true

class Companies::ProductsController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
    @products = Product.joins(user: :company)
                       .where('company_id = ?', @company.id)
                       .order('id ASC')
                       .page(params[:page])
                       .per(50)
    @users = @products.map { |product| [product.id, product.comments.map(&:user)] }.to_h
  end
end
