# frozen_string_literal: true

require 'browserless_system_test_case'

class UsersBrowserlessTest < BrowserlessSystemTestCase
  test 'show welcome message' do
    visit_with_auth '/', 'hatsuno'
    assert_text 'ようこそ'
  end
end
