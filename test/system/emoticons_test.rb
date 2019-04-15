# frozen_string_literal: true
# あとでreports_test.rbに結合する

require "application_system_test_case"

class EmoticonsTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "create a report with an emoticon" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]", with: "test")
    end
    
    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    first(".select-emoticons").select("😄")

    click_button "提出"
    assert_text "日報を保存しました。"
    assert_text "😄"
  end
end
