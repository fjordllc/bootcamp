# frozen_string_literal: true

require 'application_system_test_case'

class Course::PracticesTest < ApplicationSystemTestCase
  test 'show the course book list page' do
    visit_with_auth "/courses/#{courses(:course1).id}/books", 'kimura'
    assert_equal 'Railsプログラマーコースの参考書籍 | FBC', title
  end

  test 'disply in the list is books associated with practices of that course' do
    practice_title = 'OS X Mountain Lionをクリーンインストールする'
    visit_with_auth "/courses/#{courses(:course1).id}/books", 'kimura'
    assert_selector '.tag-links__item-link', text: practice_title

    click_link 'プラクティス', class: 'page-tabs__item-link', exact: true
    assert_text practice_title
  end

  test 'show only must-read books' do
    visit_with_auth "/courses/#{courses(:course1).id}/books", 'kimura'
    must_read_books_count = page.all('.books__items .card-books-item.a-card .a-badge.is-danger.is-sm', text: '必読').count

    click_link '必読', class: 'pill-nav__item-link', exact: true
    displayed_must_read_books_count = page.all('.books__items .card-books-item.a-card').count
    assert_equal must_read_books_count, displayed_must_read_books_count
  end
end
