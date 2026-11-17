# frozen_string_literal: true

require 'browserless_system_test_case'

module Practices
  class MentorBrowserlessTest < BrowserlessSystemTestCase
    test 'show setting for completed percentage' do
      visit_with_auth '/mentor/practices/new', 'komagata'
      assert_text '進捗の計算'
    end
  end
end
