# frozen_string_literal: true

require 'application_system_test_case'

class User::CommentsTest < ApplicationSystemTestCase
  test 'show listing comments' do
    visit_with_auth "/users/#{users(:hatsuno).id}/comments", 'hatsuno'
    assert_equal 'hatsuno | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
