# frozen_string_literal: true

class Courses::BooksController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @books = Book.filtered_books(params[:status], @course)
  end
end
