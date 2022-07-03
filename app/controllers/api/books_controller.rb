# frozen_string_literal: true

class API::BooksController < API::BaseController
  def index
    @books = Book.all # TODO: 後で順番を決める
  end
end
