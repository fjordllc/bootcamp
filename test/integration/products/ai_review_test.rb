# frozen_string_literal: true

require 'test_helper'

class Products::AiReviewTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:product8)
    @product.update!(body: '提出物本文')
    @review = @product.reload.product_ai_review
    @review.update!(status: 'completed', content: 'PRIVATE_REVIEW_SENTINEL <script>alert(1)</script>')
  end

  test 'mentor and admin see escaped private support after body before comments' do
    %i[mentormentaro komagata].each do |user|
      sign_in(user)
      get product_path(@product)
      assert_response :success
      assert_select '#product-ai-review', count: 1
      assert_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
      assert_includes response.body, '&lt;script&gt;'
      assert_not_includes response.body, '<script>alert(1)</script>'
      assert_operator response.body.index('提出物本文'), :<, response.body.index('PRIVATE_REVIEW_SENTINEL')
      sign_out
    end
  end

  test 'student and adviser HTML never includes card or support content' do
    %i[kimura advijirou].each do |user|
      sign_in(user)
      get product_path(@product)
      assert_response :success
      assert_select '#product-ai-review', count: 0
      assert_not_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
      sign_out
    end
  end

  test 'mentor markdown and product API do not disclose review' do
    sign_in(:mentormentaro)
    get product_path(@product, format: :md)
    assert_response :success
    assert_not_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
    token = create_token('mentormentaro', 'testtest')
    get api_products_path(format: :json), headers: { Authorization: "Bearer #{token}" }
    assert_response :success
    assert_not_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
    assert_not_includes response.body, 'product_ai_review'
  end

  test 'pending failed and missing configuration statuses are understandable' do
    sign_in(:mentormentaro)
    { 'pending' => 'AIレビューを作成中です', 'failed' => 'AIレビューを作成できませんでした',
      'unconfigured' => 'AIレビューの設定がされていません' }.each do |status, message|
      @review.update!(status:, content: nil)
      get product_path(@product)
      assert_response :success
      assert_includes response.body, message
    end
  end

  test 'outdated practice context and WIP do not show previous content' do
    sign_in(:mentormentaro)
    @product.practice.update!(goal: '新しい目標')
    get product_path(@product)
    assert_not_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
    @product.update!(wip: true)
    get product_path(@product)
    assert_not_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
  end

  test 'submissions still succeed if enqueue fails' do
    sign_in(:kimura)
    ProductAiReviewJob.stub(:perform_later, ->(**) { raise StandardError, 'queue unavailable' }) do
      patch product_path(@product), params: { product: { body: '変更した提出本文' }, commit: '提出する' }
    end
    assert_response :redirect
    assert_equal '変更した提出本文', @product.reload.body
    assert_equal 'failed', @review.reload.status
  end
end
