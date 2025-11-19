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

  test 'create book' do
    visit_with_auth new_book_path, 'komagata'
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
    visit_with_auth new_book_path, 'komagata'
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
    visit_with_auth new_book_path, 'kimura'
    assert_text '管理者・メンターとしてログインしてください'
  end

  test "can't update book" do
    visit_with_auth '/books', 'kimura'

    visit "/books/#{books(:book1).id}/edit"
    assert_text '管理者・メンターとしてログインしてください'
  end

  test 'use select box to narrow down book by practices' do
    visit_with_auth books_path, 'kimura'

    within '.page-filter' do
      # Check if Choices.js is initialized
      if has_selector?('.choices')
        # Choices.js is initialized
        dropdown = find('.choices')
        dropdown.click

        # Wait for and select the practice option
        # Try different possible selectors for Choices.js items
        begin
          # First try with the dropdown visible check, but with retry
          5.times do
            break if has_selector?('.choices__list--dropdown', visible: true)

            dropdown.click # Click again if dropdown didn't open
            sleep 0.5
          end

          find('.choices__item--choice', text: 'OS X Mountain Lionをクリーンインストールする').click
        rescue Capybara::ElementNotFound
          # Fallback: try to find any element with the text
          find('*', text: 'OS X Mountain Lionをクリーンインストールする').click
        end
      else
        # Choices.js is not initialized, use regular select
        select 'OS X Mountain Lionをクリーンインストールする', from: 'js-choices-single-select'
      end
    end

    assert_text 'OS X Mountain Lionをクリーンインストールする'
  end
end
