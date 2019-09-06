# frozen_string_literal: true

class BorrowingsController < ApplicationController
  before_action :require_login, only: %i(create destroy)

  def create
    book = Book.find(params[:book_id])
    current_user.borrow(book)
    redirect_to book_url(book), notice: "書籍を借りました。"
  end

  def destroy
    book = Book.find(params[:book_id])
    current_user.give_back(book)
    redirect_to book_url(book), notice: "書籍を返却しました。"
  end
end
