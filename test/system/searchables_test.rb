# frozen_string_literal: true

require "application_system_test_case"

class SearchablesTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "search Report" do
    within("form[name=search]") do
      fill_in "word", with: "作業"
    end
    find("#test-search").click
    assert_text "作業週1日目"
  end

  test "search Announcement" do
    within("form[name=search]") do
      fill_in "word", with: "お知らせ"
    end
    find("#test-search").click
    assert_text "お知らせ1"
  end

  test "search Practice" do
    within("form[name=search]") do
      fill_in "word", with: "Mountain"
    end
    find("#test-search").click
    assert_text "OS X Mountain Lionをクリーンインストールする"
  end

  test "search Question " do
    within("form[name=search]") do
      fill_in "word", with: "エディター"
    end
    find("#test-search").click
    assert_text "どのエディターを使うのが良いでしょうか"
  end
end
