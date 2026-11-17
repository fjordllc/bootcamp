# frozen_string_literal: true

require 'browserless_system_test_case'

class FAQBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing FAQs' do
    visit faq_path
    assert_selector '.lp-faq', count: FAQ.all.size
  end
end
