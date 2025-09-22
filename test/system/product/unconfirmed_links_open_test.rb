# frozen_string_literal: true

require 'application_system_test_case'

class Product::UnconfirmedLinksOpenTest < ApplicationSystemTestCase
  setup do
    @mentor = users(:komagata)
    @student1 = users(:kimura)
    @student2 = users(:hatsuno)

    @practice1 = practices(:practice7)
    @practice2 = practices(:practice8)
    @practice3 = practices(:practice3)

    @unchecked_no_replied_product = Product.create!(
      user: @student2,
      practice: @practice3,
      body: '未返信提出物',
      checker_id: @mentor.id
    )

     # 全ての提出物テスト用
    @product1 = Product.create!(
      user: @student1,
      practice: @practice1,
      body: '提出物1',
      checker_id: @mentor.id
    )
    @product2 = Product.create!(
      user: @student2,
      practice: @practice2,
      body: '提出物2',
      checker_id: @mentor.id
    )
  end

  # 「未返信の提出物を一括で開く」ボタン、「全ての提出物を一括で開く」ボタンの表示確認
  # unchecked_all / self_assigned / unassigned のボタン表示は、既存のコントローラテストで確認済み
  test 'mentor sees bulk open button when unchecked_no_replied products exist' do
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_selector 'button', text: '未返信の提出物を一括で開く'
  end

  test 'mentor does not see bulk open button when no unchecked_no_replied products exist' do
    unchecked_no_replied_product.checks.create!(user: @mentor)

    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_no_selector 'button', text: '未返信の提出物を一括で開く'
  end

  test 'mentor sees bulk open button when unchecked products exist' do
    visit_with_auth '/products', 'komagata'
    assert_selector 'button', text: '全ての提出物を一括で開く'
  end
end
