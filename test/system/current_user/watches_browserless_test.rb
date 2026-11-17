# frozen_string_literal: true

require 'browserless_system_test_case'

class CurrentUser::WatchesBrowserlessTest < BrowserlessSystemTestCase
  test 'show current_user watches when current_user is student' do
    visit_with_auth '/current_user/watches', 'kimura'
    assert_equal 'Watch中 | FBC', title
  end
end
