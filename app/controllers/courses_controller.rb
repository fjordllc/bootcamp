# frozen_string_literal: true

class CoursesController < ApplicationController

  def index
    @courses = Course.order(created_at: :desc)
  end

  private

  def course_params
    params.require(:course).permit(
      :title,
      :description,
      :published,
      :grant,
      category_ids: []
    )
  end
end
