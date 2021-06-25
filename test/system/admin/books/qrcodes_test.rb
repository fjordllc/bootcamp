# frozen_string_literal: true

require 'application_system_test_case'

class Admin::Books::QrcodesTest < ApplicationSystemTestCase
  test 'show qrcodes' do
    visit_with_auth '/admin/books/qrcodes', 'komagata'
    assert_text books(:book1).id.to_s
  end

  test 'show qrcode' do
    book = books(:book1)
    visit_with_auth "/admin/books/qrcodes/#{book.id}", 'komagata'
    assert_text book.id.to_s
  end
end
