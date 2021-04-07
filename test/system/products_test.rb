# frozen_string_literal: true

require 'application_system_test_case'
require 'minitest/mock'

PAGINATES_PER = 50

class ProductsTest < ApplicationSystemTestCase
  teardown do
    wait_for_vuejs
  end

  test 'see my product' do
    login_user 'yamada', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_equal "#{products(:product1).practice.title}の提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test 'admin can see a product' do
    login_user 'komagata', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_equal "#{products(:product1).practice.title}の提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test 'adviser can see a product' do
    login_user 'advijirou', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_equal "#{products(:product1).practice.title}の提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test 'graduate can see a product' do
    login_user 'sotugyou', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_equal "#{products(:product1).practice.title}の提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "user who completed the practice can see the other user's product" do
    login_user 'kimura', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_equal "#{products(:product1).practice.title}の提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "can see other user's product if it is permitted" do
    login_user 'hatsuno', 'testtest'
    visit "/products/#{products(:product3).id}"
    assert_equal "#{products(:product3).practice.title}の提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "can not see other user's product if it isn't permitted" do
    login_user 'hatsuno', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_not_equal '提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_text 'プラクティスを完了するまで他の人の提出物は見れません。'
  end

  test 'create product' do
    login_user 'yamada', 'testtest'
    visit "/products/new?practice_id=#{practices(:practice6).id}"
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "提出物を提出しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\n7日以上待ってもレビューされない場合は、気軽にメンターにメンションを送ってください。"
    assert_text 'Watch中'
  end

  test 'create product change status submitted' do
    login_user 'yamada', 'testtest'
    visit "/products/new?practice_id=#{practices(:practice6).id}"
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "提出物を提出しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\n7日以上待ってもレビューされない場合は、気軽にメンターにメンションを送ってください。"

    visit "/practices/#{practices(:practice6).id}"
    assert_equal first('.test-product').text, '提出物へ'
  end

  test 'update product' do
    login_user 'yamada', 'testtest'
    product = products(:product1)
    visit "/products/#{product.id}/edit"
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text '提出物を更新しました。'
  end

  test 'update product if product page is WIP' do
    login_user 'yamada', 'testtest'
    product = products(:product1)
    visit "/products/#{product.id}/edit"
    click_button 'WIP'
    visit "/products/#{product.id}"
    click_button '提出する'
    assert_text '提出物を更新しました。'
  end

  test 'delete product' do
    login_user 'yamada', 'testtest'
    product = products(:product1)
    visit "/products/#{product.id}"
    accept_confirm do
      click_link '削除'
    end
    wait_for_vuejs
    assert_text '提出物を削除しました。'
  end

  test 'product has a comment form ' do
    login_user 'yamada', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_selector '.thread-comment-form'
  end

  test 'admin can delete a product' do
    login_user 'komagata', 'testtest'
    product = products(:product1)
    visit "/products/#{product.id}"
    accept_confirm do
      click_link '削除'
    end
    wait_for_vuejs
    assert_text '提出物を削除しました。'
  end

  test 'setting checker on show page' do
    login_user 'komagata', 'testtest'
    visit "/products/#{products(:product1).id}"
    click_button '担当する'
    assert_button '担当から外れる'
  end

  test 'unsetting checker on show page' do
    login_user 'komagata', 'testtest'
    visit "/products/#{products(:product1).id}"
    click_button '担当する'
    click_button '担当から外れる'
    assert_button '担当する'
  end

  test 'hide checker button at product checked' do
    login_user 'machida', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_button '担当する'
    click_button '提出物を確認'
    assert_no_button '担当する'
    assert_no_button '担当から外れる'
  end

  test 'create product as WIP' do
    login_user 'yamada', 'testtest'
    visit "/products/new?practice_id=#{practices(:practice6).id}"
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'
  end

  test 'update product as WIP' do
    login_user 'yamada', 'testtest'
    product = products(:product1)
    visit "/products/#{product.id}/edit"
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'
  end

  test "Don't notify if create product as WIP" do
    login_user 'komagata', 'testtest'
    visit '/notifications'
    click_link '全て既読にする'

    login_user 'kensyu', 'testtest'
    visit "/products/new?practice_id=#{practices(:practice3).id}"
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    login_user 'komagata', 'testtest'
    visit '/notifications'
    assert_no_text "kensyuさんが「#{practices(:practice3).id}」の提出物を提出しました。"
  end

  test "Don't notify if update product as WIP" do
    login_user 'komagata', 'testtest'
    visit '/notifications'
    click_link '全て既読にする'

    login_user 'kensyu', 'testtest'
    visit "/products/new?practice_id=#{practices(:practice3).id}"
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    click_link '内容修正'
    fill_in('product[body]', with: 'test update')
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    login_user 'komagata', 'testtest'
    visit '/notifications'
    assert_no_text "kensyuさんが「#{practices(:practice3).title}」の提出物を提出しました。"
  end

  test 'setting checker' do
    login_user 'komagata', 'testtest'
    visit products_path
    click_button '担当する', match: :first
    assert_button '担当から外れる'
  end

  test 'unsetting checker' do
    login_user 'komagata', 'testtest'
    visit products_path
    click_button '担当する', match: :first
    click_button '担当から外れる', match: :first
    assert_button '担当する'
  end

  test 'click on the pager button' do
    login_user 'komagata', 'testtest'

    (PAGINATES_PER - Product.count + 1).times do |n|
      Product.create!(
        body: 'test',
        user: users(:hajime),
        practice: practices("practice#{n + 1}".to_sym)
      )
    end

    visit '/products'
    within first('.pagination') do
      find('a', text: '2').click
    end

    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'specify the page number in the URL' do
    login_user 'komagata', 'testtest'

    (PAGINATES_PER - Product.count + 1).times do |n|
      Product.create!(
        body: 'test',
        user: users(:hajime),
        practice: practices("practice#{n + 1}".to_sym)
      )
    end

    visit '/products?page=2'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'clicking the browser back button will show the previous page' do
    login_user 'komagata', 'testtest'

    (PAGINATES_PER - Product.count + 1).times do |n|
      Product.create!(
        body: 'test',
        user: users(:hajime),
        practice: practices("practice#{n + 1}".to_sym)
      )
    end

    visit '/products?page=2'
    within first('.pagination') do
      find('a', text: '1').click
    end
    page.go_back
    assert_current_path('/products?page=2')
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'When the number of pages is one, the pager will not be displayed' do
    count_of_delete = Product.count - PAGINATES_PER
    if count_of_delete.positive?
      Product.all.each_with_index do |product, index|
        product.delete

        break if index >= count_of_delete
      end
    end

    login_user 'komagata', 'testtest'

    visit '/products'

    assert_not page.has_css?('.pagination')
  end

  test 'be person on charge at comment on product of there are not person on charge' do
    login_user 'machida', 'testtest'

    visit products_not_responded_index_path
    def assigned_product_count
      find_link('自分の担当').find('.page-tabs__item-count').text.to_i
    end

    before_comment = assigned_product_count

    [
      '担当者がいない提出物の場合、担当者になる',
      '自分が担当者の場合、担当者のまま'
    ].each do |comment|
      visit "/products/#{products(:product1).id}"
      post_comment(comment)

      visit products_not_responded_index_path
      assert_equal before_comment + 1, assigned_product_count
    end
  end

  test 'be not person on charge at comment on product of there are person on charge' do
    login_user 'komagata', 'testtest'

    visit products_not_responded_index_path
    product = find('.thread-list-item', match: :first)
    product.click_button '担当する'
    show_product_path = product.find_link(href: /products/)[:href]
    logout

    login_user 'machida', 'testtest'
    visit products_not_responded_index_path

    def assigned_product_count
      find_link('自分の担当').find('.page-tabs__item-count').text.to_i
    end

    before_comment = assigned_product_count

    visit show_product_path
    post_comment('担当者がいる提出物の場合、担当者にならない')

    visit products_not_responded_index_path
    assert_equal before_comment, assigned_product_count
  end
end
