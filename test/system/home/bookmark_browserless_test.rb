# frozen_string_literal: true

require 'browserless_system_test_case'

module Home
  class BookmarkBrowserlessTest < BrowserlessSystemTestCase
    test 'not show bookmarks on dashboard when the user has no bookmarks' do
      visit_with_auth '/', 'machida'
      assert_current_path '/?_login_name=machida'
      assert_no_text '最新のブックマーク'
    end
  end
end
