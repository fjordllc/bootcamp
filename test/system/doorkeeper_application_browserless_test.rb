# frozen_string_literal: true

require 'browserless_system_test_case'

class DoorkeeperApplicationBrowserlessTest < BrowserlessSystemTestCase
  setup do
    visit_with_auth root_path, 'komagata'
    Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'https://example.com/callback',
      scopes: 'read'
    )
  end

  test 'admin can access oauth2 provider page' do
    visit oauth_applications_path
    assert_equal 'Oauth2 Provider', title
  end

  test 'admin other than admin cannot access oauth2 provider page' do
    visit_with_auth root_path, 'kimura'
    visit oauth_applications_path
    assert_text '管理者としてログインしてください'
  end
end
