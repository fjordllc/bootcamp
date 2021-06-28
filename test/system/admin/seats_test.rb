# frozen_string_literal: true

require 'application_system_test_case'

class Admin::SeatsTest < ApplicationSystemTestCase
  test 'show seats' do
    visit_with_auth '/admin/seats', 'komagata'
    assert_equal '席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'create seat' do
    visit_with_auth '/admin/seats/new', 'komagata'
    assert_equal '席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title

    within 'form[name=seat]' do
      fill_in 'seat[name]', with: 'Z'
      click_button '登録する'
    end
    assert_text '席を作成しました。'
  end

  test 'update seat' do
    visit_with_auth "/admin/seats/#{seats(:seat1).id}/edit", 'komagata'
    assert_equal '席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title

    within 'form[name=seat]' do
      fill_in 'seat[name]', with: 'Z'
      click_button '更新する'
    end
    assert_text '席を更新しました。'
  end

  test 'delete seat' do
    visit_with_auth '/admin/seats', 'komagata'
    assert_equal '席一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    accept_confirm do
      find("#seat_#{seats(:seat1).id} .js-delete").click
    end
    assert_text '席を削除しました。'
  end
end
