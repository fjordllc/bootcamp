# frozen_string_literal: true

require 'browserless_system_test_case'

class Authentication::DiscordSystemBrowserlessTest < BrowserlessSystemTestCase
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:discord, { info: { name: 'discord_name' } })
  end

  test 'cannot register discord account already setting user' do
    visit_with_auth '/current_user/edit', 'kimura'

    assert_text 'Discord アカウントは登録されています。'
    assert_no_text 'Discord アカウントを登録する'
  end
end
