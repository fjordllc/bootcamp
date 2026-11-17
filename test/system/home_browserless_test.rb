# frozen_string_literal: true

require 'browserless_system_test_case'

class HomeBrowserlessTest < BrowserlessSystemTestCase
  test 'GET /' do
    visit_with_auth '/', 'komagata'
    assert_equal 'ダッシュボード | FBC', title
  end

  test 'not show welcome message' do
    visit_with_auth '/', 'komagata'
    assert_no_text 'ようこそ'
  end

  test 'show the latest reports for students' do
    visit_with_auth '/', 'hajime'
    assert_text '最新のみんなの日報'
  end
end
