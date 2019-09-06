# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :require_login

  def show
    @book = Book.find(params[:id])
  end
end
