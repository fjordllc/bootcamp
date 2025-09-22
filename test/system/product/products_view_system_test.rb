# frozen_string_literal: true

require 'application_system_test_case'

class Product::ProductsViewSystemTest < ApplicationSystemTestCase
  setup do
    @mentor = users(:komagata)
    @student1 = users(:hajime)
    @student2 = users(:hatsuno)

    @practice1 = practices(:practice9)
    @practice2 = practices(:practice10)

    Notification.stub(:create!, nil) do
      Watch.stub(:create!, nil) do
        # 自分が担当かつ未返信提出物
        @unchecked_no_replied_product = Product.create!(
          user: @student2,
          practice: @practice1,
          body: '未返信提出物',
          checker_id: @mentor.id,
          published_at: 1.day.ago
        )

        # 未アサイン提出物
        @unassigned_product = Product.create!(
          user: @student1,
          practice: @practice1,
          body: '未アサイン提出物',
          checker_id: nil,
          published_at: 1.day.ago
        )

        # 自分が担当の提出物（返信済み）
        @self_assigned_product = Product.create!(
          user: @student1,
          practice: @practice2,
          body: '自分が担当している提出物',
          checker_id: @mentor.id,
          published_at: 1.day.ago,
          commented_at: 2.days.ago,
          mentor_last_commented_at: 2.days.ago
        )
      end
    end
  end

  test 'mentor sees unchecked_no_replied products links' do
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
 
    assert_selector "a.js-unconfirmed-link[href$='#{@unchecked_no_replied_product.id}']", count: 1, wait: 5
  end

  test 'mentor sees unassigned products links' do
    visit_with_auth '/products/unassigned', 'komagata'

    assert_selector "a.js-unconfirmed-link[href$='#{@unassigned_product.id}']", count: 1, wait: 5
  end

  test 'mentor sees self_assigned products links' do
    visit_with_auth '/products/self_assigned', 'komagata'

    assert_selector "a.js-unconfirmed-link[href$='#{@self_assigned_product.id}']", count: 1
    assert_selector "a.js-unconfirmed-link[href$='#{@unchecked_no_replied_product.id}']", count: 1
  end
end
