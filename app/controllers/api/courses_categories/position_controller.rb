# frozen_string_literal: true

class API::CoursesCategories::PositionController < API::BaseController
  wrap_parameters :courses_category

  def update
    @courses_category = CoursesCategory.find(params[:courses_category_id])
    if @courses_category.update(courses_category_params)
      head :no_content
    else
      render json: @courses_category.errors, status: :unprocessable_entity
    end
  end

  private

  def courses_category_params
    params.require(:courses_category).permit(:position)
  end
end
