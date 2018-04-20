require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "GET /" do
    visit "/welcome"
    assert_equal "FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
