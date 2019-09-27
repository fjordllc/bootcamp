# frozen_string_literal: true

class Admin::Books::QrcodesController < AdminController
  layout "qrcodes"
  DESPLAY_NUM = 12

  def index
    @books = Book.all
  end
end
