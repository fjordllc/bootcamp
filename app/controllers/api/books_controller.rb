# frozen_string_literal: true

class API::BooksController < API::BaseController
  def index
    @books = Book.with_attached_cover.includes(:practices)
  end
end
