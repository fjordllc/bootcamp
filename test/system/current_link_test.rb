require "application_system_test_case"

class CurrentLinkTest < ApplicationSystemTestCase
  test "is-activeが適切にcssでクラスに設定されるか確認" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "machida")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal current_path, "/users"
    assert_selector "a.global-nav-links__link.is-active[href='/users']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "プラクティス"
    assert_equal current_path, "/practices"
    assert_selector "a.global-nav-links__link.is-active[href='/practices']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "rubyをインストールする"
    assert_selector "a.global-nav-links__link.is-active[href='/practices']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "このプラクティスに関する日報"
    assert_selector "a.global-nav-links__link.is-active[href='/reports']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "日報"
    assert_equal current_path, "/reports"
    assert_selector "a.global-nav-links__link.is-active[href='/reports']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "Q&A"
    assert_equal current_path, "/questions"
    assert_selector "a.global-nav-links__link.is-active[href='/questions']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "みんなのブログ"
    assert_equal current_path, "/feeds"
    assert_selector "a.global-nav-links__link.is-active[href='/feeds']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "wiki"
    assert_equal current_path, "/pages"
    assert_selector "a.global-nav-links__link.is-active[href='/pages']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "ユーザー情報"
    assert_equal current_path, "/admin/users"
    assert_selector "a.global-nav-links__link.is-active[href='/admin/users']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "カテゴリー"
    assert_equal current_path, "/admin/categories"
    assert_selector "a.global-nav-links__link.is-active[href='/admin/categories']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    click_link "管理ページ"
    assert_equal current_path, "/admin"
    assert_selector "a.global-nav-links__link.is-active[href='/admin']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1
  end
end
