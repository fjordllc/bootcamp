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
                       .order_for_not_wip_list
                       .first
      assert_text newest_product.body
    end
  end

  test 'products order on unchecked tab' do
    # id順で並べたときの最初と最後の提出物を、提出日順で見たときに最新と最古になるように入れ替える
    Product.update_all(created_at: 1.day.ago, published_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
    # 最古の提出物を画面上で判定するため、提出物を1ページ内に収める
    Product.unchecked.not_wip.limit(Product.count - Product.default_per_page).delete_all
    newest_product = Product.unchecked.not_wip.reorder(:id).first
    newest_product.update(published_at: Time.current)
    oldest_product = Product.unchecked.not_wip.reorder(:id).last
    oldest_product.update(published_at: 2.days.ago)

    visit_with_auth '/products/unchecked', 'komagata'

    # 提出日の降順で並んでいることを検証する
    titles = all('.thread-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.thread-list-item-meta .a-user-name').map(&:text)
    assert_equal "#{newest_product.practice.title}の提出物", titles.first
    assert_equal newest_product.user.login_name, names.first
    assert_equal "#{oldest_product.practice.title}の提出物", titles.last
    assert_equal oldest_product.user.login_name, names.last
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
end
