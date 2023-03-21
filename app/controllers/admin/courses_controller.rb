# frozen_string_literal: true

class Admin::CoursesController < AdminController
  before_action :set_course, only: %i[edit update]

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to mentor_courses_path, notice: 'コースを作成しました。'
    else
      render :new
    end
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
