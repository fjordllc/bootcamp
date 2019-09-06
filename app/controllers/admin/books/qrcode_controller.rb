# frozen_string_literal: true

class Admin::Books::QrcodeController < AdminController
  layout "qrcode"

  def show
    @book = Book.find(params[:book_id])
  end
end
