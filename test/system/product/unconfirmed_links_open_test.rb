# frozen_string_literal: true

require 'application_system_test_case'

class Product::UnconfirmedLinksOpenTest < ApplicationSystemTestCase
  setup do
    @mentor = users(:komagata)
    @student1 = users(:hatsuno)
    @practice1 = practices(:practice9)

    # 自分が担当かつ未返信提出物
    @self_assigned_no_replied_product = Product.create!(
      user: @student1,
      practice: @practice1,
      body: '未返信提出物',
      checker_id: @mentor.id,
      published_at: 1.day.ago
    )
  end

  # 「全ての提出物を一括で開く」ボタンの表示確認（それ以外のボタンはそれぞれのコントローラテストで確認済み）
  test 'mentor sees bulk open button when unchecked products exist' do
    visit_with_auth '/products', 'komagata'
    assert_selector 'button', text: '全ての提出物を一括で開く'
  end

  # リンク存在を確認するテスト
  test 'mentor sees unchecked_no_replied products links' do
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'

    assert_selector "a.js-unconfirmed-link[href$='#{@self_assigned_no_replied_product.id}']", count: 1, wait: 5
  end
end
