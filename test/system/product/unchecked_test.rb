# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/product_helper'

class Product::UncheckedTest < ApplicationSystemTestCase
  include ProductHelper

  test 'non-staff user can not see listing unchecked products' do
    visit_with_auth '/products/unchecked', 'hatsuno'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'advisor can not see listing unchecked products' do
    visit_with_auth '/products', 'advijirou'
    assert_no_link '未完了'
  end

  test 'mentor can see a button to open to open all unchecked products' do
    visit_with_auth '/products/unchecked', 'komagata'
    assert_button '未完了の提出物を一括で開く'
  end

  test 'click on open all unchecked submissions button' do
    delete_most_unchecked_products!
    visit_with_auth '/products/unchecked', 'komagata'
    click_button '未完了の提出物を一括で開く'
    within_window(windows.last) do
      newest_product = Product
                       .unchecked
                       .not_wip
                       .ascending_by_date_of_publishing_and_id
                       .first
      assert_text newest_product.body
    end
  end

  test 'products order on unchecked tab' do
    oldest_product = products(:product14)
    newest_product = products(:product26)

    # 提出日の昇順で並んでいることを検証する
    visit_with_auth '/products/unchecked', 'komagata'
    assert_equal 'Terminalの基礎を覚える', oldest_product.practice.title

    visit_with_auth '/products/unchecked?page=2', 'komagata'
    assert_equal 'sshdでパスワード認証を禁止にする', newest_product.practice.title
  end

  test 'not display products in listing unchecked if unchecked products all checked' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:mentormentaro)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'komagata'
    click_button '提出物を合格にする'
    visit_with_auth '/products/unchecked?target=unchecked_all', 'komagata'
    assert_no_text product.practice.title
  end

  test 'display no-replied products if click on unchecked-tab' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'kimura'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    visit_with_auth '/products/unchecked', 'komagata'
    click_link '自分の担当'
    assert_text product.practice.title
  end

  test 'display no-comment products if click on no-replied-button' do
    product = products(:product8)
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_text product.practice.title
  end

  test 'display products last commented by submitter if click on no-replied-button' do
    product = products(:product8)
    visit_with_auth "/products/#{product.id}", 'kimura'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    within('.thread-comment.is-latest') do
      assert_text 'kimura'
      assert_text 'test'
    end
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_text product.practice.title
    assert_selector '.card-list-item-meta__item', text: '提出者'
  end

  test 'not display products last commented by mentor if click on no-replied-button' do
    product = products(:product8)
    visit_with_auth "/products/#{product.id}", 'mentormentaro'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    accept_alert '提出物の担当になりました。'
    within('.thread-comment.is-latest') do
      assert_text 'mentormentaro'
      assert_text 'test'
    end
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_no_text product.practice.title
    assert_no_selector '.card-list-item-meta__item', text: 'メンター'
  end

  test 'display no-replied products if click on unchecked-all-button' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'kimura'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    visit_with_auth '/products/unchecked?target=unchecked_all', 'komagata'
    click_link '自分の担当'
    assert_text product.practice.title
  end

  test 'not display replied products if click on no-replied-button' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'komagata'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_no_text product.practice.title
  end

  test 'show incomplete' do
    visit_with_auth '/products/unchecked', 'komagata'
    assert_link '未完了'
    assert_text '未完了の提出物'
  end

  test 'button name is incomplete list' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    assert_link '未完了一覧'
  end

  test "show only mentor's products if you select a mentor in products unchecked all" do
    user = users(:kimura)
    practice = practices(:practice47)
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )

    visit_with_auth '/products/unchecked', 'mentormentaro'
    find('.choices__list').click
    find('#choices--js-choices-single-select-item-choice-2', text: 'komagata').click
    find('.pill-nav__item-link', text: '全て').click
    assert_current_path("/products/unchecked?checker_id=#{product.checker_id}&target=unchecked_all")
    assert_selector '.card-list-item__assignee-name', text: 'komagata'
    assert_no_selector '.card-list-item__assignee-name', text: 'machida'
  end

  test "show only mentor's products if you select a mentor in products unchecked no replied" do
    user = users(:kimura)
    practice = practices(:practice47)
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )

    visit_with_auth '/products/unchecked', 'mentormentaro'
    find('.choices__list').click
    find('#choices--js-choices-single-select-item-choice-2', text: 'komagata').click
    find('.pill-nav__item-link', text: '未返信').click
    assert_current_path("/products/unchecked?checker_id=#{product.checker_id}&target=unchecked_no_replied")
    assert_selector '.card-list-item__assignee-name', text: 'komagata'
    assert_no_selector '.card-list-item__assignee-name', text: 'machida'
  end

  test 'the number of products in the unchecked tab excludes hibernated user' do
    visit_with_auth '/products/unchecked', 'komagata'
    expected_count = Product.unhibernated_user_products.unchecked.not_wip.count
    assert_selector '.page-tabs__item-link.is-active', text: "未完了 （#{expected_count}）"
  end

  test 'unchecked products is excepted hiberanated user' do
    hiberanated_user = users(:kyuukai)
    practice = practices(:practice47)

    Product.create!(
      body: 'hiberanated user product.',
      user: hiberanated_user,
      practice:,
      checker_id: nil
    )

    product_hiberanated_user_name = "#{hiberanated_user.login_name} (#{hiberanated_user.name_kana})"

    visit_with_auth '/products/unchecked', 'komagata'
    # assert_no_text だとデータが読み込まれる前に実行され常に成立してしまうため、明示的に待機する has_text? を使用する
    assert_not has_text?(product_hiberanated_user_name)
    first('.pagination__item-link', text: '2').click
    assert_not has_text?(product_hiberanated_user_name)

    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_not has_text?(product_hiberanated_user_name)
    first('.pagination__item-link', text: '2').click
    assert_not has_text?(product_hiberanated_user_name)
  end
end
