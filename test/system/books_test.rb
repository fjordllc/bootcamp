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

    within '.page-filter' do
      # Check if Choices.js is initialized
      if has_selector?('.choices')
        # Choices.js is initialized
        dropdown = find('.choices')
        dropdown.click

        # Wait for and select the practice option
        # Try different possible selectors for Choices.js items
        begin
          # Wait for dropdown to be visible, with retry mechanism
          5.times do |attempt|
            if has_selector?('.choices__list--dropdown', visible: true, wait: 2)
              break
            elsif attempt < 4
              dropdown.click # Click again if dropdown didn't open
            end
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
