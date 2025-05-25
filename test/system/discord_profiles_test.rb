# frozen_string_literal: true

require 'application_system_test_case'

class DiscordProfilesTest < ApplicationSystemTestCase
  test 'incremental search by discord_account' do
    visit_with_auth '/users', 'komagata'
    assert_equal 24, all('.users-item').length
    fill_in 'js-user-search-input', with: 'kimura1234'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura Tadasi', count: 1
  end

  test 'show times link on user page' do
    kimura = users(:kimura)

    visit_with_auth "/users/#{kimura.id}", 'hatsuno'
    assert_text 'kimura'
    assert_no_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')

    kimura.discord_profile.update!(times_url: 'https://discord.com/channels/715806612824260640/123456789000000007')

    visit current_path
    assert_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')
  end

  test 'show times link on user list page' do
    visit_with_auth '/users', 'hatsuno'
    assert_selector '.page-header__title', text: 'ユーザー'

    fill_in 'js-user-search-input', with: 'Kimura Tadasi'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura Tadasi'
    assert_no_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')

    kimura = users(:kimura)
    kimura.discord_profile.update!(times_url: 'https://discord.com/channels/715806612824260640/123456789000000007')

    visit current_url
    assert_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')
  end
end
