# frozen_string_literal: true

require 'test_helper'

class Products::SeededAiReviewTest < ActionDispatch::IntegrationTest
  test 'fictional seeded review is associated with product13 and staff only' do
    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('db/fixtures'), :product_ai_reviews)
    product = products(:product13)
    review = ProductAiReview.find_by!(product:)

    assert_match(/fictional|sample/i, review.content)

    %i[mentormentaro komagata].each do |user|
      sign_in(user)
      get product_path(product)
      assert_response :success
      assert_select '#product-ai-review', count: 1
      assert_select '#product-ai-review h2', text: '表示確認用の架空レビュー'
      assert_select '#product-ai-review a[href="https://example.invalid/sample"]', text: '架空の参照先'
      assert_includes response.body, 'FICTIONAL_AI_REVIEW_SAMPLE'
      assert_includes response.body, '&lt;script&gt;'
      assert_includes response.body, '&lt;/script&gt;'
      assert_select '#product-ai-review script', count: 0
      sign_out
    end

    %i[kimura advijirou].each do |user|
      sign_in(user)
      get product_path(product)
      assert_response :success
      assert_select '#product-ai-review', count: 0
      assert_not_includes response.body, 'FICTIONAL_AI_REVIEW_SAMPLE'
      sign_out
    end
  end
end
