# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/product_helper'

class Product::UnassignedTest < ApplicationSystemTestCase
  include ProductHelper

  test 'non-staff user can not see listing unassigned products' do
    visit_with_auth '/products/unassigned', 'hatsuno'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'advisor can not see listing unassigned products' do
    visit_with_auth '/products', 'advijirou'
    assert_no_link '未アサイン'
  end

  test 'mentor can see a button to open to open all unassigned products' do
    visit_with_auth '/products/unassigned', 'komagata'
    assert_button '未アサインの提出物を一括で開く'
  end

  test 'click on open all unassigned submissions button' do
    delete_most_unassigned_products!
    visit_with_auth '/products/unassigned', 'komagata'
    click_button '未アサインの提出物を一括で開く'
    within_window(windows.last) do
      newest_product = Product
                       .unassigned
                       .unchecked
                       .not_wip
                       .ascending_by_date_of_publishing_and_id
                       .first
      assert_text newest_product.body
    end
  end

  test 'products order on unassigned tab' do
    oldest_product = products(:product14)
    newest_product = products(:product26)

    visit_with_auth '/products/unassigned', 'komagata'

    # 提出日の昇順で並んでいることを検証する
    assert_equal 'Terminalの基礎を覚える', oldest_product.practice.title
    assert_equal 'sshdでパスワード認証を禁止にする', newest_product.practice.title
  end

  test 'display elapsed days label and number of products' do
    unassigned_products = Product.unassigned.not_wip.unchecked

    visit_with_auth '/products/unassigned', 'komagata'
    within '.page-body__column.is-main' do
      assert_text "6日以上経過（#{unassigned_products.count { |product| product.elapsed_days >= 6 }}）"
      assert_text "5日経過（#{unassigned_products.count { |product| product.elapsed_days == 5 }}）"
      assert_text "4日経過（#{unassigned_products.count { |product| product.elapsed_days == 4 }}）"
      assert_text "今日提出（#{unassigned_products.count { |product| product.elapsed_days.zero? }}）"
    end
  end

  test 'show elapsed days links that jump to elements on the same page' do
    visit_with_auth '/products/unassigned', 'komagata'
    within '.page-nav__items.elapsed-days' do
      assert_link('6日以上経過', href: '#elapsed-6days')
      assert has_selector?('li.is-active', text: '6日以上経過')
      assert_link('1日経過', href: '#elapsed-1days')
      assert has_selector?('li.is-inactive', text: '1日経過')
    end
  end
end
