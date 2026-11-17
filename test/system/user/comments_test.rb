# frozen_string_literal: true

require 'browserless_system_test_case'

class User::CommentsTest < BrowserlessSystemTestCase
  test 'show listing comments' do
    visit_with_auth "/users/#{users(:hatsuno).id}/comments", 'hatsuno'
    assert_equal 'hatsunoさんのコメント | FBC', title
  end
end
