# frozen_string_literal: true

require 'browserless_system_test_case'

module Pages
  class WipBrowserlessTest < BrowserlessSystemTestCase
    test 'show a WIP Doc on Docs list page' do
      visit_with_auth pages_path, 'kimura'
      assert_text 'WIPのテスト'
      element = all('.card-list-item__rows').find { |component| component.has_text?('WIPのテスト') }
      within element do
        assert_selector '.a-list-item-badge.is-wip', text: 'WIP'
        assert_selector '.a-meta', text: 'Docs作成中'
      end
    end
  end
end
