class ProductsController < ApplicationController
  before_action :require_login
  before_action :set_practice
  before_action :set_my_product, only: %i(show edit update destroy)

  def show
  end

  def new
    @product = @practice.products.new(user: current_user)
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    @product.practice = @practice
    @product.user = current_user

    if @product.save
      redirect_to [@product.practice, @product], notice: "提出物を作成しました。"
    else
      render :new
    end
  end

  def update
    if @product.update(product_params)
      redirect_to [@product.practice, @product], notice: "提出物を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to @practice, notice: "提出物を削除しました。"
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_my_product
      if product_displayable?(practice: @practice)
        @product = @practice.products.find_by(id: params[:id])
      else
        @product = @practice.products.find_by(id: params[:id], user: current_user)
      end
    end

    def product_params
      params.require(:product).permit(:body)
    end
end
