# frozen_string_literal: true

require 'test_helper'

class Products::AiReviewTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:product8)
    @product.update!(body: '提出物本文')
    @review = @product.create_product_ai_review!(content: 'PRIVATE_REVIEW_SENTINEL <script>alert(1)</script>')
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

  test 'empty or missing review does not show a card' do
    sign_in(:mentormentaro)
    @review.update!(content: '  ')
    get product_path(@product)
    assert_response :success
    assert_select '#product-ai-review', count: 0
    @review.destroy!
    get product_path(@product)
    assert_select '#product-ai-review', count: 0
  end

  test 'body edits and WIP do not show previous content' do
    sign_in(:mentormentaro)
    @product.update!(body: '新しい本文')
    get product_path(@product)
    assert_not_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
    @review.update!(content: 'PRIVATE_REVIEW_SENTINEL')
    @product.update!(wip: true)
    get product_path(@product)
    assert_not_includes response.body, 'PRIVATE_REVIEW_SENTINEL'
  end

  test 'submissions still succeed if enqueue fails' do
    sign_in(:kimura)
    ProductAiReviewJob.stub(:perform_later, ->(*) { raise StandardError, 'queue unavailable' }) do
      patch product_path(@product), params: { product: { body: '変更した提出本文' }, commit: '提出する' }
    end
    assert_response :redirect
    assert_equal '変更した提出本文', @product.reload.body
    assert_nil @review.reload.content
  end
end
