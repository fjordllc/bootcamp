# frozen_string_literal: true

require 'application_system_test_case'

class BooksTest < ApplicationSystemTestCase
  test 'show listing books' do
    visit_with_auth '/books', 'komagata'
    assert_equal '参考書籍 | FBC', title
    assert has_link?(practices(:practice1).title, href: practice_path(practices(:practice1)))
  end

  test 'create book' do
    visit_with_auth new_book_url, 'komagata'
    within 'form[name=book]' do
      fill_in 'book[title]', with: books(:book1).title
      fill_in 'book[price]', with: books(:book1).price
      fill_in 'book[page_url]', with: books(:book1).page_url
      fill_in 'book[description]', with: books(:book1).description
      click_on '内容を保存'
    end
    assert_text '参考書籍を作成しました'
  end

  test 'update book' do
    visit_with_auth "/books/#{books(:book1).id}/edit", 'komagata'
    within 'form[name=book]' do
      fill_in 'book[title]', with: 'ゼロからわかるRuby超入門(修正)'
      click_button '内容を保存'
    end
    assert_text '参考書籍を更新しました'
  end

  test 'destroy book' do
    visit_with_auth "/books/#{books(:book1).id}/edit", 'komagata'
    accept_confirm do
      click_link '削除'
    end
    assert_text '参考書籍を削除しました'
  end

  test 'title & body not allow blank' do
    visit_with_auth new_book_url, 'komagata'
    within 'form[name=book]' do
      fill_in 'book[title]', with: ''
      fill_in 'book[price]', with: ''
      fill_in 'book[page_url]', with: ''
      click_on '内容を保存'
    end
    assert_text 'タイトルを入力してください'
    assert_text '価格を入力してください'
    assert_text '価格は数値で入力してください'
    assert_text 'URLを入力してください'
  end

  test "can't create book" do
    visit_with_auth new_book_url, 'kimura'
    assert_text '管理者・メンターとしてログインしてください'
  end

  test "can't update book" do
    visit_with_auth '/books', 'kimura'

    visit "/books/#{books(:book1).id}/edit"
    assert_text '管理者・メンターとしてログインしてください'
  end

  test 'use select box to narrow down book by practices' do
    visit_with_auth books_path, 'kimura'
    find('.choices__inner').click
    page_practices = page.all('.choices__item--choice').map(&:text).size
    course_practices = users(:kimura).course.practices.size + 1
    assert_equal page_practices, course_practices

    find('#choices--js-choices-single-select-item-choice-2', text: 'OS X Mountain Lionをクリーンインストールする').click
    assert_text 'OS X Mountain Lionをクリーンインストールする'
  end
end
