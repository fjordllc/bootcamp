# frozen_string_literal: true

require 'application_system_test_case'

class Practice::MemoTest < ApplicationSystemTestCase
  test 'update mentor memo without page transitions' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-2').click
    click_button '編集'
    fill_in('js-practice-memo', with: 'メンター向けメモをページ遷移せず編集')
    click_button '保存する'
    assert_text '保存しました'
    assert_text 'メンター向けメモをページ遷移せず編集'
  end
end
