# frozen_string_literal: true

require 'application_system_test_case'

class Product::UncheckedTest < ApplicationSystemTestCase
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
      user: user,
      practice: practice,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'komagata'
    click_button '提出物を確認'
    visit_with_auth '/products/unchecked?target=unchecked_all', 'komagata'
    assert_no_text product.practice.title
  end

  test 'display no-replied products if click on unchecked-tab' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user: user,
      practice: practice,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'kimura'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    visit_with_auth '/products/unchecked', 'komagata'
    click_link '自分の担当'
    assert_text product.practice.title
  end

  test 'display no-replied products if click on no-replied-button' do
    product = products(:product8)
    visit_with_auth "/products/#{product.id}", 'kimura'
    fill_in('new_comment[description]', with: 'test')
    click_button 'コメントする'
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_text product.practice.title
  end

  test 'display no-replied products if click on unchecked-all-button' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user: user,
      practice: practice,
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
      user: user,
      practice: practice,
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
      user: user,
      practice: practice,
      checker_id: checker.id
    )

    visit_with_auth '/products/unchecked', 'mentormentaro'
    find('.choices__list').click
    find('#choices--js-choices-single-select-item-choice-2', text: 'komagata').click
    find('.pill-nav__item-link', text: '全て').click
    assert_current_path("/products/unchecked?checker_id=#{product.checker_id}&target=unchecked_all")
    assert_selector '.card-list-item__assignee-name', text: 'komagata'
  end

  test "show only mentor's products if you select a mentor in products unchecked no replied" do
    user = users(:kimura)
    practice = practices(:practice47)
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user: user,
      practice: practice,
      checker_id: checker.id
    )

    visit_with_auth '/products/unchecked', 'mentormentaro'
    find('.choices__list').click
    find('#choices--js-choices-single-select-item-choice-2', text: 'komagata').click
    find('.pill-nav__item-link', text: '未返信').click
    assert_current_path("/products/unchecked?checker_id=#{product.checker_id}&target=unchecked_no_replied")
    assert_selector '.card-list-item__assignee-name', text: 'komagata'
  end
end
