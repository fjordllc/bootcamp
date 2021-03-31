# frozen_string_literal: true

require 'application_system_test_case'

class HomeTest < ApplicationSystemTestCase
  test 'GET / without sign in' do
    logout
    visit '/'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /' do
    login_user 'komagata', 'testtest'
    visit '/'
    assert_equal 'ダッシュボード | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET / without github account ' do
    login_user 'hajime', 'testtest'
    visit '/'
    within('.card-list__item-link.is-github') do
      assert_text 'GitHubアカウントを登録してください。'
    end
  end

  test 'GET / with github account' do
    user = users(:hajime)
    user.github_account = 'hajime'
    login_user user, 'testtest'

    visit '/'
    assert_no_selector '.card-list__item-link.is-github'
  end

  test 'GET / without slack account' do
    login_user 'hajime', 'testtest'
    visit '/'
    within('.card-list__item-link.is-slack') do
      assert_text 'Slackアカウントを登録してください。'
    end
  end

  test 'GET / with slack_account' do
    user = users(:hajime)
    user.slack_account = 'hajime'
    login_user user, 'testtest'

    visit '/'
    assert_no_selector '.card-list__item-link.is-slack'
  end

  test 'GET / without discord_account' do
    login_user 'hajime', 'testtest'

    visit '/'
    within('.card-list__item-link.is-discord') do
      assert_text 'Discordアカウントを登録してください。'
    end
  end

  test 'GET / with discord_account' do
    user = users(:hajime)
    user.discord_account = 'hajime#1111'
    login_user user, 'testtest'

    visit '/'
    assert_no_selector '.card-list__item-link.is-discord'
  end
end
