# frozen_string_literal: true

require 'browserless_system_test_case'

class Check::ProductsBrowserlessTest < BrowserlessSystemTestCase
  test 'user can see stamp' do
    visit_with_auth "/products/#{products(:product3).id}", 'kimura'
    assert_text '合格'
  end
end
