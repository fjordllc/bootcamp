# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :require_login

  def index
    @books = Book.order(:title).page(params[:page])
  end

  def show
    @book = Book.find(params[:id])
  end
end
