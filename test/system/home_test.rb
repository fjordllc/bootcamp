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
    login_user "hajime", "testtest"
    visit "/"
    within(".incompleted-account-alert__item.is-github") do
      assert_text "GitHub"
    end
  end

  test "GET / with github account" do
    user = users(:hajime)
    user.github_account = "hajime"
    login_user user, "testtest"

    visit "/"
    assert_no_selector ".incompleted-account-alert__item.is-github"
  end

  test "GET / without slack account" do
    login_user "hajime", "testtest"
    visit "/"
    within(".incompleted-account-alert__item.is-slack") do
      assert_text "Slack"
    end
  end

  test "GET / with slack_account" do
    user = users(:hajime)
    user.slack_account = "hajime"
    login_user user, "testtest"

    visit "/"
    assert_no_selector ".incompleted-account-alert__item.is-slack"
  end
end
