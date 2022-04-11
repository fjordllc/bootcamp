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
    assert_equal 'OS X Mountain Lionをクリーンインストールする', oldest_product.practice.title
    assert_equal 'sshdでパスワード認証を禁止にする', newest_product.practice.title
  end

  test 'display elapsed days label' do
    visit_with_auth '/products/unassigned', 'komagata'
    assert_text '0日経過'
    assert_text '5日経過'
    assert_text '6日経過'
    assert_text '7日以上経過'
  end
end
