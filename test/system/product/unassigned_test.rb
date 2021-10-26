# frozen_string_literal: true

require 'application_system_test_case'

class Product::UnassignedTest < ApplicationSystemTestCase
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
    visit_with_auth '/products/unassigned', 'komagata'

    click_button '未アサインの提出物を一括で開く'

    within_window(windows.last) do
      newest_product = Product
                       .unassigned
                       .unchecked
                       .not_wip
                       .order_for_not_wip_list
                       .first
      assert_text newest_product.body
    end
  end

  test 'products order on unassigned tab' do
    # id順で並べたときの最初と最後の提出物を、提出日順で見たときに最新と最古になるように入れ替える
    Product.update_all(created_at: 1.day.ago, published_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
    newest_product = Product.unassigned.unchecked.not_wip.reorder(:id).first
    newest_product.update(published_at: Time.current)
    oldest_product = Product.unassigned.unchecked.not_wip.reorder(:id).last
    oldest_product.update(published_at: 2.days.ago)

    visit_with_auth '/products/unassigned', 'komagata'

    # 提出日の降順で並んでいることを検証する
    titles = all('.thread-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.thread-list-item-meta .a-user-name').map(&:text)
    assert_equal "#{newest_product.practice.title}の提出物", titles.first
    assert_equal newest_product.user.login_name, names.first
    assert_equal "#{oldest_product.practice.title}の提出物", titles.last
    assert_equal oldest_product.user.login_name, names.last
  end
end
