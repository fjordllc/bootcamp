# frozen_string_literal: true

class API::BooksController < API::BaseController
  def index
    books = Book.all
    books = params[:practice_id].present? ? books.joins(:practices).where(practices: { id: params[:practice_id] }) : books
    @books = books
             .with_attached_cover
             .includes(:practices)
             .order(updated_at: :desc, id: :desc)
  end
end
