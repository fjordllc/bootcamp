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

  test 'non-staff user can not see listing not-responded products' do
    login_user 'hatsuno', 'testtest'
    visit '/products/not_responded'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'advisor can not see listing not-responded products' do
    login_user 'advijirou', 'testtest'
    visit '/products'
    assert_no_link '未返信'
  end

  test 'mentor can see a button to open to open all not-responded products' do
    login_user 'komagata', 'testtest'
    visit '/products/not_responded'
    assert_button '未返信の提出物を一括で開く'
  end

  test 'click on open all not-responded submissions button' do
    login_user 'komagata', 'testtest'
    visit '/products/not_responded'

    click_button '未返信の提出物を一括で開く'

    within_window(windows.last) do
      assert_text 'テストの提出物1です。'
    end
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

  test 'delete product' do
    login_user 'yamada', 'testtest'
    product = products(:product1)
    visit "/products/#{product.id}"
    accept_confirm do
      click_link '削除'
    end
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
    assert_text '提出物を削除しました。'
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

  test 'Slack notify if the create product' do
    login_user 'kensyu', 'testtest'
    visit "/products/new?practice_id=#{practices(:practice3).id}"
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '提出する'
      assert_match "kensyu さんが「#{practices(:practice3).title}」の提出物を提出しました。", mock_log.to_s
    end
    assert_text "提出物を提出しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\n7日以上待ってもレビューされない場合は、気軽にメンターにメンションを送ってください。"
  end

  test 'Slack notify if the create product as WIP' do
    login_user 'kensyu', 'testtest'
    visit "/products/new?practice_id=#{practices(:practice3).id}"
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button 'WIP'
      assert_no_match "kensyu さんが「#{practices(:practice3).title}」の提出物を提出しました。", mock_log.to_s
    end
    assert_text '提出物をWIPとして保存しました。'
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
    login_user 'komagata', 'testtest'

    visit '/products'

    assert_not page.has_css?('.pagination')
  end
end
