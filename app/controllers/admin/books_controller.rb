# frozen_string_literal: true

class Admin::BooksController < AdminController
  before_action :set_book, only: %i(show edit update destroy)

  def index
    @books = Book.order(:title).page(params[:page])
  end

  def show
  end

  def new
    @book = Book.new
  end

  def edit
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to admin_books_url, notice: "書籍を登録しました。"
    else
      render action: "new"
    end
  end

  def update
    if @book.update(book_params)
      redirect_to admin_books_url, notice: "書籍を更新しました。"
    else
      render action: "edit"
    end
  end

  def destroy
    @book.destroy
    redirect_to admin_books_url, notice: "書籍を削除しました。"
  end

  private
    def set_book
      @book = Book.find(params[:id])
    end

    def book_params
      params.require(:book).permit(
        :title,
        :isbn,
        :borrowed
      )
    end
end
