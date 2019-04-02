# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :require_login
  before_action :check_permission!, only: %i(show)
  before_action :require_admin_adviser_or_mentor_login, only: :index

  def index
    @products = Product.order(created_at: :desc).page(params[:page])
  end

  def show
    @product = find_product
    @practice = find_practice
    @footprints = find_footprints
    footprint!
  end

  def new
    @practice = find_practice
    @product = @practice.products.new(user: current_user)
  end

  def edit
    @practice = find_practice
    @product = find_product
  end

  def create
    @product = Product.new(product_params)
    @practice = find_practice
    @product.practice = @practice
    @product.user = current_user

    if @product.save
      redirect_to @product, notice: "提出物を作成しました。"
    else
      render :new
    end
  end

  def update
    @product = find_product
    if @product.update(product_params)
      redirect_to @product, notice: "提出物を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @product = find_product
    @product.destroy
    if current_user.admin?
      redirect_to products_url, notice: "提出物を削除しました。"
    else
      redirect_to @product.practice, notice: "提出物を削除しました。"
    end
  end

  private
    def find_product
      Product.find_by(id: params[:id])
    end

    def find_practice
      if params[:practice_id]
        Practice.find(params[:practice_id])
      else
        find_product.practice
      end
    end

    def find_footprints
      find_product.footprints.order(created_at: :desc)
    end

    def footprint!
      if find_product.user != current_user
        find_product.footprints.where(user: current_user).first_or_create
      end
    end

    def check_permission!
      unless policy(find_product).show?
        redirect_to root_path, alert: "プラクティスを完了するまで他の人の提出物は見れません。"
      end
    end

    def product_params
      params.require(:product).permit(:body)
    end
end
