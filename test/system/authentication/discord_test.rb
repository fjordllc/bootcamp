# frozen_string_literal: true

require 'application_system_test_case'

class Authentication::DiscordSystemTestCase < ApplicationSystemTestCase
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:discord, { info: { name: 'discord_name' } })
  end

  test 'cannot register discord account already setting user' do
    visit_with_auth '/current_user/edit', 'kimura'

    assert_text 'Discord アカウントは登録されています。'
    assert_no_text 'Discord アカウントを登録する'
  end

  test 'can register discord account not setting user' do
    visit_with_auth '/current_user/edit', 'hatsuno'

    click_link 'Discord アカウントを登録する'
    assert_text 'Discordと連携しました'

    visit '/current_user/edit'
    assert_text 'Discord アカウントは登録されています。'
  end
end
