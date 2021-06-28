# frozen_string_literal: true

require 'application_system_test_case'

class Book::BorrwedTest < ApplicationSystemTestCase
  test 'show listing borrowed books' do
    visit_with_auth '/books/borrowed', 'kimura'
    assert_equal '貸出中の書籍一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
