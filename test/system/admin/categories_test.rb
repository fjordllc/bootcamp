# frozen_string_literal: true

require "application_system_test_case"

class Admin::CategoriesTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show listing categories" do
    visit "/admin/categories"
    assert_equal "カテゴリー | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create category" do
    visit "/admin/categories/new"
    within "form[name=category]" do
      fill_in "category[name]", with: "テストカテゴリー"
      fill_in "category[slug]", with: "test-category"
      fill_in "category[description]", with: "テストのカテゴリーです。"
      click_button "登録する"
    end
    assert_text "カテゴリーを作成しました。"
  end

  test "update category" do
    visit "/admin/categories/#{categories(:category_1).id}/edit"
    within "form[name=category]" do
      fill_in "category[name]", with: "テストカテゴリー"
      fill_in "category[slug]", with: "test-category"
      fill_in "category[description]", with: "テストのカテゴリーです。"
      click_button "更新する"
    end
    assert_text "カテゴリーを更新しました。"
  end

  test "delete category" do
    visit "/admin/categories"
    accept_confirm do
      find("#category_#{categories(:category_1).id} .js-delete").click
    end
    assert_text "カテゴリーを削除しました。"
  end
end
