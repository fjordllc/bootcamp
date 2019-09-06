# frozen_string_literal: true

require "application_system_test_case"

class Admin::Books::QrcodeTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show qrcode" do
    book = books(:book_1)
    visit "/admin/books/#{book.id}/qrcode"
    assert_text "#{book.id}"
  end
end
