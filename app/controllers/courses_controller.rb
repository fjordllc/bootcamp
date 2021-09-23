# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :require_login
  before_action :require_admin_login, except: %i[index]
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
      redirect_to courses_path, notice: 'コースを作成しました。'
    else
      render :new
    end
  end

  def update
    if @course.update(course_params)
      redirect_to courses_path, notice: 'コースを更新しました。'
    else
      render :edit
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
      :open_course,
      category_ids: []
    )
  end
end
