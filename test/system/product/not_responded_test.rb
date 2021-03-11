# frozen_string_literal: true

require 'application_system_test_case'

class ProductsTest < ApplicationSystemTestCase
  teardown do
    wait_for_vuejs
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
      newest_product = Product
                       .not_responded_products
                       .reorder_for_not_responded_products
                       .first
      assert_text newest_product.body
    end
  end

  test 'products order' do
    # id順で並べたときの最初と最後の提出物を、提出日順で見たときに最新と最古になるように入れ替える
    Product.update_all(published_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
    newest_product = Product.not_responded_products.reorder(:id).first
    newest_product.update(published_at: Time.current)
    oldest_product = Product.not_responded_products.reorder(:id).last
    oldest_product.update(published_at: 2.days.ago)

    login_user 'komagata', 'testtest'
    visit '/products/not_responded'

    # 提出日の昇順で並んでいることを検証する
    titles = all('.thread-list-item__title').map { |t| t.text.gsub('★', '') }
    authors = all('.thread-list-item-meta .thread-header__author').map(&:text)
    assert_equal "#{newest_product.practice.title}の提出物", titles.first
    assert_equal newest_product.user.login_name, authors.first
    assert_equal "#{oldest_product.practice.title}の提出物", titles.last
    assert_equal oldest_product.user.login_name, authors.last
  end
end
