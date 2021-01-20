# frozen_string_literal: true

class Courses::PracticesSortController < ApplicationController
  before_action :require_admin_login

  def index
    @course = Course.find(params[:course_id])
    @categories = @course.categories
                         .order(:position)
                         .includes(:practices)
  end
end
