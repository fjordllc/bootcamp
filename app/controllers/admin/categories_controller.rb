# frozen_string_literal: true

class Admin::CategoriesController < AdminController
  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to mentor_categories_url, notice: 'カテゴリーを作成しました。'
    else
      render action: 'new'
    end
  end

  private

  def category_params
    params.require(:category).permit(
      :name,
      :slug,
      :description
    )
  end
end
