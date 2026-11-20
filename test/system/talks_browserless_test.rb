# frozen_string_literal: true

require 'browserless_system_test_case'

class TalksBrowserlessTest < BrowserlessSystemTestCase
  test 'admin can see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    assert_selector '.page-tabs'
  end

  test 'non-admin user cannot see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    assert_no_selector '.page-tabs'
  end
end
