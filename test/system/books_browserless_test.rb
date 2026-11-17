# frozen_string_literal: true

require 'browserless_system_test_case'

class BooksBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing books when logged in with student account' do
    visit_with_auth '/books', 'kimura'
    assert_equal '参考書籍 | FBC', title
    assert has_link?(practices(:practice1).title, href: practice_path(practices(:practice1)))
  end

  test 'show listing books when logged in with admin account' do
    visit_with_auth '/books', 'komagata'
    assert_equal '参考書籍 | FBC', title
    assert has_link?(practices(:practice1).title, href: practice_path(practices(:practice1)))
  end
end
