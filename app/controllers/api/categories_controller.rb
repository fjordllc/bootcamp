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
end
