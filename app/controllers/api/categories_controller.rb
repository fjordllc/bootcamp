# frozen_string_literal: true

class API::CategoriesController < API::BaseController
  def index
    @categories =
      if params[:course_id]
        Course.find(params[:course_id]).categories.order(:created_at)
      else
        Category.order(:created_at)
      end
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      head :no_content
    else
      head :bad_request
    end
  end
end
