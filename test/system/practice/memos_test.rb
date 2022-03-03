# frozen_string_literal: true

require 'application_system_test_case'

class Practice::MemoTest < ApplicationSystemTestCase
  # TODO: リトライすると通るが、最後のアサーションでよくfailする。テキストエリアへの入力がうまくいってない？
  test 'update mentor memo without page transitions' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-2').click
    click_button '編集'
    practice = products(:product2).practice
    assert_changes -> { practice.reload.memo } do
      fill_in('js-practice-memo', with: '') # テスト安定化のために実験的に追加してみた
      fill_in('js-practice-memo', with: 'メンター向けメモをページ遷移せず編集')
      click_button '保存する'
      assert_text '保存しました'
    end
    assert_text 'メンター向けメモをページ遷移せず編集'
  end
end
