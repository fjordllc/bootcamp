# frozen_string_literal: true

require 'browserless_system_test_case'

class Admin::FAQBrowserlessTest < BrowserlessSystemTestCase
  test 'display listing FAQs' do
    visit_with_auth '/admin/faqs', 'komagata'
    assert_text 'FAQ一覧'
  end
end
