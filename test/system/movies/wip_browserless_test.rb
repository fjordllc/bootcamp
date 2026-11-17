# frozen_string_literal: true

require 'browserless_system_test_case'

module Movies
  class WipBrowserlessTest < BrowserlessSystemTestCase
    test 'show a WIP movie on movie list page' do
      visit_with_auth movies_path, 'kimura'
      assert_text 'WIPのテスト'
      element = all('.thumbnail-card.a-card').find { |component| component.has_text?('WIPのテスト') }
      within element do
        assert_selector '.a-title-label.is-wip', text: 'WIP'
      end
    end
  end
end
