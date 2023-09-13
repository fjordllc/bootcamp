# frozen_string_literal: true

class Mentor::CoursesController < MentorController
  before_action :set_course, only: %i[edit update]

  def index; end

  def new
    @course = Course.new
  end

  def edit; end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to mentor_courses_path, notice: 'コースを作成しました。'
    else
      render :new
    end
  end

  def update
    if @course.update(course_params)
      redirect_to mentor_courses_path, notice: 'コースを更新しました。'
    else
      render :edit
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(
      :title,
      :description,
      :published,
      category_ids: []
    )
  end
end
