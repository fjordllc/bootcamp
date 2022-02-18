# frozen_string_literal: true

require 'application_system_test_case'

class User::WorksTest < ApplicationSystemTestCase
  test 'show portfolio' do
    visit_with_auth "/users/#{users(:hatsuno).id}/portfolio", 'hatsuno'
    assert_equal 'hatsuno | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
