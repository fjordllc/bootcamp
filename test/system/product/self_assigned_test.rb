# frozen_string_literal: true

require 'application_system_test_case'
require 'minitest/mock'

class ProductsTest < ApplicationSystemTestCase
  teardown do
    wait_for_vuejs
  end

  test 'non-staff user can not see listing self-assigned products' do
    login_user 'hatsuno', 'testtest'
    visit '/products/self_assigned'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'advisor can not see listing self-assigned products' do
    login_user 'advijirou', 'testtest'
    visit '/products'
    assert_no_link '自分の担当'
  end

  test 'mentor can see a button to open to open all self-assigned products' do
    login_user 'komagata', 'testtest'
    checker = users(:komagata)
    Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )
    visit '/products/self_assigned'
    assert_button '自分の担当の提出物を一括で開く'
  end

  test 'click on open all self-assigned submissions button' do
    login_user 'komagata', 'testtest'
    checker = users(:komagata)
    Product.create!(
      body: '自分の担当の提出物です。',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )
    visit '/products/self_assigned'

    click_button '自分の担当の提出物を一括で開く'

    within_window(windows.last) do
      assert_text '自分の担当の提出物です。'
    end
  end

  test 'not display products in listing self-assigned if self-assigned products all checked' do
    login_user 'komagata', 'testtest'
    product = products(:product3)
    checker = users(:komagata)
    product.checker_id = checker.id
    product.save
    visit '/products/self_assigned'
    assert_text 'レビューを担当する提出物はありません'
  end
end
