# frozen_string_literal: true

require 'application_system_test_case'
require 'minitest/mock'

class ProductsTest < ApplicationSystemTestCase
  teardown do
    wait_for_vuejs
  end

  test 'non-staff user can not see listing unchecked products' do
    login_user 'hatsuno', 'testtest'
    visit '/products/unchecked'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'advisor can not see listing unchecked products' do
    login_user 'advijirou', 'testtest'
    visit '/products'
    assert_no_link '未チェック'
  end

  test 'mentor can see a button to open to open all unchecked products' do
    login_user 'komagata', 'testtest'
    visit '/products/unchecked'
    assert_button '未チェックの提出物を一括で開く'
  end

  test 'click on open all unchecked submissions button' do
    login_user 'komagata', 'testtest'
    visit '/products/unchecked'

    click_button '未チェックの提出物を一括で開く'

    within_window(windows.last) do
      assert_text 'テストの提出物1です。'
    end
  end
end
