# frozen_string_literal: true

require "application_system_test_case"

class Admin::SeatsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  test "show seats" do
    visit "/admin/seats"
    assert_equal "席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create seat" do
    visit "/admin/seats/new"
    assert_equal "席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    within "form[name=seat]" do
      fill_in "seat[name]", with: "Z"
      click_button "登録する"
    end
    assert_text "席を作成しました。"
  end

  test "update seat" do
    visit "/admin/seats/#{seats(:seat_1).id}/edit"
    assert_equal "席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    within "form[name=seat]" do
      fill_in "seat[name]", with: "Z"
      click_button "更新する"
    end
    assert_text "席を更新しました。"
  end

  test "delete seat" do
    visit "/admin/seats"
    assert_equal "席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    accept_confirm do
      find("#seat_#{seats(:seat_1).id} .js-delete").click
    end
    assert_text "席を削除しました。"
  end
end
