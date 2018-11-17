# frozen_string_literal: true

require "application_system_test_case"

class CoursesTest < ApplicationSystemTestCase
  test "show listing courses" do
    login_user "yamada", "testtest"
    visit "/courses"
    assert_equal "コース | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create course" do
    login_user "komagata", "testtest"
    visit "/courses/new"
    within "form[name=course]" do
      fill_in "course[title]", with: "テストコース"
      fill_in "course[description]", with: "テストのコースです。"
      click_button "内容を保存"
    end
    assert_text "コースを作成しました。"
  end

  test "update course" do
    login_user "komagata", "testtest"
    visit "/courses/#{courses(:course_1).id}/edit"
    within "form[name=course]" do
      fill_in "course[title]", with: "テストコース"
      fill_in "course[description]", with: "テストのコースです。"
      click_button "内容を保存"
    end
    assert_text "コースを更新しました。"
  end

  test "delete course" do
    login_user "komagata", "testtest"
    visit "/courses"
    accept_confirm do
      find("#course_#{courses(:course_3).id} .js-delete").click
    end
    assert_text "コースを削除しました。"
  end
end
