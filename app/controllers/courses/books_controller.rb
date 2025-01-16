# frozen_string_literal: true

class Courses::BooksController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @books = Book.with_attached_cover
                 .eager_load(:practices_books, practices: { categories: :courses_categories })
                 .where(courses_categories: { course_id: @course.id })
                 .where(must_read_status)
                 .order(updated_at: :desc, id: :desc)
  end

  private

  def must_read_status
    params[:status] == 'mustread' ? { practices_books: { must_read: true } } : {}
  end
end
