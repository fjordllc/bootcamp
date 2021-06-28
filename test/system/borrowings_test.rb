# frozen_string_literal: true

require 'application_system_test_case'

class BorrowingsTest < ApplicationSystemTestCase
  test 'borrow and return book' do
    book = books(:book2)
    visit_with_auth "books/#{book.id}", 'komagata'
    click_button '借りる'
    assert_text '書籍を借りました。'
    click_button '返却する'
    assert_text '書籍を返却しました。'
  end

  test 'show borrowed when the book is borrowed' do
    book = books(:book1)
    visit_with_auth "books/#{book.id}", 'komagata'
    assert_text '貸出中'
  end
end
