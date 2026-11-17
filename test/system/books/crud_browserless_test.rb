# frozen_string_literal: true

require 'browserless_system_test_case'

module Books
  class CrudBrowserlessTest < BrowserlessSystemTestCase
    test "can't create book" do
      visit_with_auth new_book_path, 'kimura'
      assert_text '管理者・メンターとしてログインしてください'
    end

    test "can't update book" do
      visit_with_auth '/books', 'kimura'

      visit "/books/#{books(:book1).id}/edit"
      assert_text '管理者・メンターとしてログインしてください'
    end
  end
end
