# frozen_string_literal: true

require 'application_system_test_case'

class BooksTest < ApplicationSystemTestCase
  test 'show listing books when logged in with student account' do
    visit_with_auth '/books', 'kimura'
    assert_equal '参考書籍 | FBC', title
    assert has_link?(practices(:practice1).title, href: practice_path(practices(:practice1)))
  end

  test 'show listing books when logged in with admin account' do
    visit_with_auth '/books', 'komagata'
    assert_equal '参考書籍 | FBC', title
    assert has_link?(practices(:practice1).title, href: practice_path(practices(:practice1)))
  end

  test 'use select box to narrow down book by practices' do
    visit_with_auth books_path, 'kimura'

    find('.page-filter .choices__inner').click
    within '.page-filter .choices__list--dropdown' do
      find('.choices__item--choice', text: 'OS X Mountain Lionをクリーンインストールする').click
    end

    assert_text 'OS X Mountain Lionをクリーンインストールする'
  end
end
