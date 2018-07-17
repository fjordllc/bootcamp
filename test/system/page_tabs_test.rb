require "application_system_test_case"

class PageTabsTest < ApplicationSystemTestCase
  test "プラクティス、日報、提出物のタブをクリックする" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "machida")
      fill_in("user[password]", with: "testtest")
    end

    click_button "サインイン"
    click_link "プラクティス"
    first(".category-practices-item__title-link").click
    practice_id = current_path.split("/").last.to_i

    page.all(".page-tabs__item-link")[0].click
    assert_text "終了条件"

    page.all(".page-tabs__item-link")[1].click
    expected_report_counts = Practice.find(practice_id).reports.size
    actual_report_counts = page.all(".user-reports-item__link").size
    assert_equal actual_report_counts, expected_report_counts

    page.all(".page-tabs__item-link")[2].click
    assert_text "提出物"
    expected_products_counts = Practice.find(practice_id).products.size
    actual_products_counts = page.all(".user-reports-item__link").size
    assert_equal actual_products_counts, expected_products_counts
  end
end
