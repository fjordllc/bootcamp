# frozen_string_literal: true

module PracticesHelper
  def all_books
    Book.all.collect { |book| [book.id, book.title] }
  end
end
