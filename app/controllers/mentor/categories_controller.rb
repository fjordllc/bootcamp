# frozen_string_literal: true

class Mentor::CategoriesController < MentorController
  before_action :set_category, except: %i[index]

  def index; end

  def show; end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to return_to, notice: 'カテゴリーを更新しました。'
    else
      render action: 'edit'
    end
  end

  def destroy
    @category.destroy
    redirect_to mentor_categories_url, notice: 'カテゴリーを削除しました。'
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

  def return_to
    course_id = params[:category][:course_id]
    course_id.present? ? course_practices_url(course_id) : mentor_categories_url
  end
end
