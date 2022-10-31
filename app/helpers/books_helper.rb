# frozen_string_literal: true

module BooksHelper
  def must_read_for_any_practices?(book)
    book.practices_books.any?(&:must_read)
  end
end
