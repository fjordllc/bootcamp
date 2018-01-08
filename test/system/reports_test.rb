require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  def practices
    visit "/practices"
    all(".category-practices-item__value.is-title").map { |e| e.text }
  end

  test "equal practices order in practices and new report" do
    visit "/reports/new"
    report_practices = page.all(".select-practices__label-title").map { |e| e.text }
    assert_equal practices, report_practices
  end

  test "equal practices order in practices and edit report" do
    visit "/reports/#{reports(:report_1).id}/edit"
    report_practices = page.all(".select-practices__label-title").map { |e| e.text }
    assert_equal practices, report_practices
  end
end
