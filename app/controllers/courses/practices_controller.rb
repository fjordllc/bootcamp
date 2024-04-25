# frozen_string_literal: true

class Courses::PracticesController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @categories = @course.categories.order(:created_at)
    @learnings = current_user.learnings
  end
end
