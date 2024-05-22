# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :require_mentor_login, except: %i[index list]
  skip_before_action :require_active_user_login, only: %i[list]

  def index
    @courses = Course.order(created_at: :desc)
  end

  def list
    @courses = Course.all
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
