# frozen_string_literal: true

require 'browserless_system_test_case'

class DiscordProfilesBrowserlessTest < BrowserlessSystemTestCase
  test 'show times link on user page' do
    kimura = users(:kimura)

    visit_with_auth "/users/#{kimura.id}", 'hatsuno'
    assert_text 'kimura'
    assert_no_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')

    kimura.discord_profile.update!(times_url: 'https://discord.com/channels/715806612824260640/123456789000000007')

    visit current_path
    assert_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')
  end
end
