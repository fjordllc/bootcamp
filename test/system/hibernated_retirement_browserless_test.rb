# frozen_string_literal: true

require 'browserless_system_test_case'

class HibernatedRetirementBrowserlessTest < BrowserlessSystemTestCase
  test 'redirect to retirement page when logged in' do
    visit_with_auth new_hibernated_retirement_path, 'hatsuno'

    assert_current_path new_retirement_path
  end
end
