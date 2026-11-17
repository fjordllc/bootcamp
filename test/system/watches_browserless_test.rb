# frozen_string_literal: true

require 'browserless_system_test_case'

class WatchesBrowserlessTest < BrowserlessSystemTestCase
  test 'the Watch button is displayed on a movie page' do
    visit_with_auth "/movies/#{movies(:movie1).id}", 'komagata'
    assert_selector '.watch-toggle'
    assert_text 'Watch'
  end
end
