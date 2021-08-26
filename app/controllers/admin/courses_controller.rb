# frozen_string_literal: true

class Admin::CoursesController < AdminController
  def index
    @courses = Course.order(created_at: :desc)
  end
end
