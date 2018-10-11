# frozen_string_literal: true

require "application_system_test_case"

class ProductLinkTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "don't show [提出物を作る] link if user don't have to  submit product" do
    visit "/practices/#{practices(:practice_1).id}/edit"
    page.uncheck("practice_submission")
    click_button "更新する"
    assert_equal "/practices/#{practices(:practice_1).id}", current_path
    assert_no_link "提出物を作る"
  end

  test "show [提出物を作る] or [提出物] link if user don't have to  submit product" do
    visit "/practices/#{practices(:practice_1).id}/edit"
    page.check("practice_submission")
    click_button "更新する"
    assert_equal "/practices/#{practices(:practice_1).id}", current_path
    assert_link "提出物を作る"
  end
end
