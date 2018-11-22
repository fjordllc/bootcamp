# frozen_string_literal: true

class Admin::CategoriesController < AdminController
  before_action :set_category, only: %i(show edit update destroy)

  def index
    @categories = Category.order("position")
  end

  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_url, notice: "カテゴリーを作成しました。"
    else
      render action: "new"
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_url, notice: "カテゴリーを更新しました。"
    else
      render action: "edit"
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_url, notice: "カテゴリーを削除しました。"
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(
        :name,
        :slug,
        :description
      )
    end
end
