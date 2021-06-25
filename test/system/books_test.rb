# frozen_string_literal: true

require 'application_system_test_case'

class BooksTest < ApplicationSystemTestCase
  test 'show listing books' do
    visit_with_auth books_path, 'hatsuno'
    assert_text '書籍一覧'
  end

  test 'search books' do
    visit_with_auth books_path, 'hatsuno'
    within('form[name=book_search]') do
      fill_in 'word', with: '現場'
    end
    find('#book-search').click
    assert_text "'現場'の検索結果"
  end
end
