# frozen_string_literal: true

require 'application_system_test_case'

class Practice::MemoTest < ApplicationSystemTestCase
  test 'update mentor memo without page transitions' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    check 'toggle-mentor-memo-body', allow_label_click: true, visible: false
    click_button '編集'
    assert_field('practice[memo]', with: '「OS X Mountain Lionをクリーンインストールする」のメンターメモ')
    practice = products(:product2).practice
    assert_changes -> { practice.reload.memo } do
      fill_in('js-practice-memo', with: 'メンター向けメモをページ遷移せず編集')
      click_button '保存する'
      assert_text '保存しました'
    end
    assert_text 'メンター向けメモをページ遷移せず編集'
  end
end
