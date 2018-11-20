# frozen_string_literal: true

require "application_system_test_case"

class SearchablesTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "search with 'Bootcamp'" do
    within("form[name=search]") do
      fill_in "word", with: "Bootcamp"
    end
    find("#test-search").click
    assert_equal "'Bootcamp'の検索結果 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
