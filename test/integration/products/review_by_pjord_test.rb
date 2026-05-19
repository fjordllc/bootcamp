# frozen_string_literal: true

require 'test_helper'

class Products::ReviewByPjordTest < ActionDispatch::IntegrationTest
  test 'mentor can create product review comment by Pjord' do
    product = products(:product1)

    ProductAiReviewer.stub(:review, 'レビュー本文') do
      assert_difference -> { product.comments.count } do
        post review_by_pjord_product_path(product, _login_name: 'komagata')
      end
    end

    comment = product.comments.order(:created_at).last
    assert_redirected_to product_path(product, anchor: 'comments')
    assert_equal users(:pjord), comment.user
    assert_equal 'レビュー本文', comment.description
  end

  test 'student cannot create product review comment by Pjord' do
    product = products(:product1)

    assert_no_difference -> { product.comments.count } do
      post review_by_pjord_product_path(product, _login_name: 'kimura')
    end

    assert_redirected_to root_path
  end

  test 'admin without mentor role cannot create product review comment by Pjord' do
    product = products(:product1)

    assert_no_difference -> { product.comments.count } do
      post review_by_pjord_product_path(product, _login_name: 'adminonly')
    end

    assert_redirected_to root_path
  end

  test 'redirects with alert when Pjord user is missing' do
    product = products(:product1)

    Pjord.stub(:user, nil) do
      assert_no_difference -> { product.comments.count } do
        post review_by_pjord_product_path(product, _login_name: 'komagata')
      end
    end

    assert_redirected_to product_path(product)
    assert_equal 'ピヨルドのレビューコメントを作成できませんでした。', flash[:alert]
  end

  test 'redirects with alert when product review fails' do
    product = products(:product1)

    ProductAiReviewer.stub(:review, ->(_product) { raise StandardError, 'error' }) do
      assert_no_difference -> { product.comments.count } do
        post review_by_pjord_product_path(product, _login_name: 'komagata')
      end
    end

    assert_redirected_to product_path(product)
    assert_equal 'ピヨルドのレビューコメントを作成できませんでした。', flash[:alert]
  end
end
