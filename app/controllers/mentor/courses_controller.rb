# frozen_string_literal: true

class Mentor::CoursesController < MentorController
  before_action :set_course, only: %i[edit update]

  def index
    @courses = Course.order(created_at: :desc)
  end

  def new
    if params[:course_id].present?
      original_course = Course.find(params[:course_id])
      @course = Course.new(category_ids: original_course.category_ids)
    else
      @course = Course.new
    end
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
      :summary,
      :published,
      category_ids: []
    )
  end
end
