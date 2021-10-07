# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :require_login
  before_action :require_admin_login, except: %i[index]
  before_action :set_course, only: %i[destroy]

  def index
    @courses = Course.order(created_at: :desc)
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to courses_path, notice: 'コースを作成しました。'
    else
      render :new
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_path, notice: 'コースを削除しました。'
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
