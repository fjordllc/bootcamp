# frozen_string_literal: true

require 'browserless_system_test_case'

module Talks
  class ContentBrowserlessTest < BrowserlessSystemTestCase
    test 'display company-logo in consultation room when user is trainee' do
      visit_with_auth "/talks/#{talks(:talk11).id}", 'kensyu'
      assert_selector 'img[class="page-content-header__company-logo-image"]'
    end
  end
end
