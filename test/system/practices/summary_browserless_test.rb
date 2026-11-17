# frozen_string_literal: true

require 'browserless_system_test_case'

module Practices
  class SummaryBrowserlessTest < BrowserlessSystemTestCase
    test 'not show the summary ( summary_text: no / ogp_image: no )' do
      practice = practices(:practice1)
      visit_with_auth practice_path(practice), 'komagata'

      assert_no_selector '.a-card', text: '概要'
    end
  end
end
