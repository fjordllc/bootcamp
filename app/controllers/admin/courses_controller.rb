# frozen_string_literal: true

class Admin::CoursesController < AdminController
  before_action :set_course, only: %i[edit update destroy]

  def index
    @courses = Course.order(created_at: :desc)
  end

  def new
    @course = Course.new
  end

  def edit; end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to admin_courses_path, notice: 'コースを作成しました。'
    else
      render :new
    end
  end

  def update
    if @course.update(course_params)
      redirect_to admin_courses_path, notice: 'コースを更新しました。'
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
