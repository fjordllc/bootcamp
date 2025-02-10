# frozen_string_literal: true

class Courses::PracticesController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @categories = @course.categories.includes(practices: %i[practices_books learning_minute_statistic started_or_submitted_students]).order(:created_at)
    @learnings = current_user.learnings
  end
end
