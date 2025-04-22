# frozen_string_literal: true

class CoursesController < ApplicationController
  def index
    @courses = Course.order(created_at: :desc)
  end
end
