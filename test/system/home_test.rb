# frozen_string_literal: true

require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "GET / without sign in" do
    logout
    visit "/"
    assert_equal "FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "GET /" do
    login_user "komagata", "testtest"
    visit "/"
    assert_equal "ダッシュボード | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "GET / without github account " do
    login_user "muryou", "testtest"
    visit "/"
    within(".alert_github_account") do
      assert_text "GitHubアカウントが未入力です"
    end
  end

  test "GET / with github account" do
    user = users(:muryou)
    user.github_account = "muryou"
    login_user user, "testtest"

    visit "/"
    assert_no_selector ".alert_github_account"
  end

  test "GET / without slack account" do
    login_user "muryou", "testtest"
    visit "/"
    within(".alert_slack_account") do
      assert_text "Slackアカウントが未入力です"
    end
  end

  test "GET / with slack_account" do
    user = users(:muryou)
    user.slack_account = "muryou"
    login_user user, "testtest"

    visit "/"
    assert_no_selector ".alert_slack_account"
  end
end
