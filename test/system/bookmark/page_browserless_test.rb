# frozen_string_literal: true

require 'browserless_system_test_case'

class Bookmark::PageBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @page = pages(:page1)
  end

  test 'show page bookmark on lists' do
    visit_with_auth '/current_user/bookmarks', 'kimura'
    assert_text @page.title
  end
end
