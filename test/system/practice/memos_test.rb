# frozen_string_literal: true

require 'application_system_test_case'

class Practice::MemoTest < ApplicationSystemTestCase
  test 'update mentor memo without page transitions' do
    login_user 'komagata', 'testtest'
    visit "/products/#{products(:product2).id}"
    wait_for_vuejs
    click_button '編集'
    fill_in('js-practice-memo', with: 'メンター向けメモをページ遷移せず編集')
    click_button '保存する'
    wait_for_vuejs
    assert_text 'メンター向けメモをページ遷移せず編集'
  end
end
