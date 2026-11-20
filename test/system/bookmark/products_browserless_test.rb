# frozen_string_literal: true

require 'browserless_system_test_case'

class Bookmark::ProductBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @product = products(:product1)
  end

  test 'show product bookmark on lists' do
    visit_with_auth '/current_user/bookmarks', 'kimura'
    assert_text @product.title
  end
end
