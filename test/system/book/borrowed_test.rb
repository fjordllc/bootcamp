# frozen_string_literal: true

require 'application_system_test_case'

class Book::BorrwedTest < ApplicationSystemTestCase
  setup { login_user 'hatsuo', 'testtest' }

  test 'show listing borrowed books' do
    visit '/books/borrowed'
    assert_equal '貸出中の書籍一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
