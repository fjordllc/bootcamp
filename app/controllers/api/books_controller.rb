# frozen_string_literal: true

class API::BooksController < API::BaseController
  def index
    @books = Book.all
  end
end
