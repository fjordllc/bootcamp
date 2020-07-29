# frozen_string_literal: true

class Books::BorrowedController < ApplicationController
  def index
    @books = Book.borrowed.order(:title).page(params[:page])
  end
end
