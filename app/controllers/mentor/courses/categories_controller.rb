# frozen_string_literal: true

class Mentor::Courses::CategoriesController < ApplicationController
  before_action :require_mentor_login

  def index
    @course = Course.find(params[:course_id])
    @courses_categories = @course
                          .courses_categories
                          .includes(:category)
                          .order(:position)
  end
end
