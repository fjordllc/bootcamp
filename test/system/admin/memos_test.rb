# frozen_string_literal: true

require "application_system_test_case"

class Admin::MemosTest < ApplicationSystemTestCase
  setup do
    login_user "komagata", "testtest"
  end

  test "show memos" do
    visit "/admin/memos"
    assert_equal "メモ一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create memo" do
    visit "/admin/memos/new"
    assert_equal "メモ一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    fill_in "memo[body]", with: "memomemo"
    select "2018", from: :memo_date_1i
    select "11", from: :memo_date_2i
    select "13", from: :memo_date_3i
    click_button "登録する"
    assert_text "メモを作成しました。"
  end

  test "update memo" do
    visit "/admin/memos/#{memos(:memo_1).id}/edit"
    assert_equal "メモ一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    fill_in "memo[body]", with: "memomemo"
    select "2018", from: :memo_date_1i
    select "11", from: :memo_date_2i
    select "13", from: :memo_date_3i
    click_button "更新する"
    assert_text "メモを更新しました。"
  end

  test "delete memo" do
    visit "/admin/memos"
    accept_confirm do
      find("#memo_#{memos(:memo_1).id} .js-delete").click
    end
    assert_text "メモを削除しました。"
  end
end
