# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :require_mentor_login, except: %i[index]

  def index
    @courses = Course.order(created_at: :desc)
  end

  private

  def course_params
    params.require(:course).permit(
      :title,
      :description,
      :published,
      category_ids: []
    )
  end
end
