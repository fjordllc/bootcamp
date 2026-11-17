# frozen_string_literal: true

require 'browserless_system_test_case'

class Products::CheckerBrowserlessTest < BrowserlessSystemTestCase
  test 'can see unassigned-tab' do
    visit_with_auth products_path, 'komagata'
    assert find('.page-tabs__item-link', text: '未アサイン')
  end
end
