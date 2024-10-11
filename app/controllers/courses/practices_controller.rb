# frozen_string_literal: true

class Courses::PracticesController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @categories = @course.categories.includes(practices: %i[practices_books learning_minute_statistic started_students]).order(:created_at)
    @learnings = current_user.learnings
    @user_course_practice = UserCoursePractice.new(current_user)
    @completed_practices_size_by_category = @user_course_practice.completed_practices_size_by_category
  end
end
