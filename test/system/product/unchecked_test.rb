# frozen_string_literal: true

require 'application_system_test_case'

class ProductsTest < ApplicationSystemTestCase
  test 'non-staff user can not see listing unchecked products' do
    visit_with_auth '/products/unchecked', 'hatsuno'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'advisor can not see listing unchecked products' do
    visit_with_auth '/products', 'advijirou'
    assert_no_link '未チェック'
  end

  test 'mentor can see a button to open to open all unchecked products' do
    visit_with_auth '/products/unchecked', 'komagata'
    assert_button '未チェックの提出物を一括で開く'
  end

  test 'click on open all unchecked submissions button' do
    visit_with_auth '/products/unchecked', 'komagata'

    click_button '未チェックの提出物を一括で開く'

    within_window(windows.last) do
      assert_text 'テストの提出物1です。'
    end
  end

  test 'renamed unchecked to incomplete' do
    login_user 'komagata', 'testtest'
    visit '/products/unchecked'
    assert_link '未完了'
    assert_text '未完了の提出物'
  end

  test 'button name is incomplete list' do
    login_user 'komagata', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_link '未完了一覧'
  end
end
