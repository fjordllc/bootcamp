# frozen_string_literal: true

require 'browserless_system_test_case'

class User::WorksTest < BrowserlessSystemTestCase
  test 'show portfolio' do
    visit_with_auth "/users/#{users(:hatsuno).id}/portfolio", 'hatsuno'
    assert_equal 'hatsunoさんのポートフォリオ | FBC', title
  end
end
