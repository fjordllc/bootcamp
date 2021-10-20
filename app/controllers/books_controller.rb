class BooksController < ApplicationController
  before_action :set_book, only: %i[edit update destroy]
  before_action :require_admin_or_mentor_login, only: %i[new create edit update]

  def index
    @books= Book.all
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to books_path, notice: '参考書籍を作成しました'
    else
      render :new
    end
  end

  def edit; end

  def destroy
    @book.destroy
    redirect_to books_path, notice: '参考書籍を削除しました'
  end

  def update
    if @book.update(book_params)
      redirect_to books_path, notice: '参考書籍を更新しました'
    else
      render :edit
    end
  end

  private

  def book_params
    params.require(:book).permit(
      :title,
      :price,
      :page_url,
      :cover,
      :description
    )
  end

  def set_book
    @book = Book.find(params[:id])
  end 
end
