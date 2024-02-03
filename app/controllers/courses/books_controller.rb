# frozen_string_literal: true

class Courses::BooksController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
  end
end
