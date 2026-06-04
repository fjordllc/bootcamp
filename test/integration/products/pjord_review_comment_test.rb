# frozen_string_literal: true

require 'test_helper'

class Products::PjordReviewCommentTest < ActionDispatch::IntegrationTest
  test 'creates product review comment by Pjord when product is submitted' do
    Pjord::ProductReviewAgent.stub(:review, 'レビュー本文') do
      perform_enqueued_jobs do
        post products_path(_login_name: 'hatsuno'),
             params: { practice_id: practices(:practice6).id, product: { body: '提出物です。' }, commit: '提出する' }
      end
    end

    product = Product.order(:created_at).last
    comment = product.comments.order(:created_at).last
    assert_redirected_to product_path(product)
    assert_equal users(:pjord), comment.user
    assert_equal 'レビュー本文', comment.description
  end

  test 'does not create product review comment by Pjord when product is saved as WIP' do
    Pjord::ProductReviewAgent.stub(:review, 'レビュー本文') do
      assert_no_enqueued_jobs only: PjordProductReviewJob do
        post products_path(_login_name: 'hatsuno'),
             params: { practice_id: practices(:practice6).id, product: { body: 'WIPです。' }, commit: 'WIP' }
      end
    end
  end

  test 'creates product review comment by Pjord when WIP product is submitted' do
    product = products(:product5)

    Pjord::ProductReviewAgent.stub(:review, 'レビュー本文') do
      perform_enqueued_jobs do
        patch product_path(product, _login_name: 'kimura'),
              params: { product: { body: product.body }, commit: '提出する' }
      end
    end

    comment = product.comments.order(:created_at).last
    assert_redirected_to product_path(product)
    assert_equal users(:pjord), comment.user
    assert_equal 'レビュー本文', comment.description
  end

  test 'does not create product review comment by Pjord when submitted product is updated' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review, 'レビュー本文') do
      assert_no_enqueued_jobs only: PjordProductReviewJob do
        patch product_path(product, _login_name: 'kimura'),
              params: { product: { body: '更新しました。' }, commit: '提出する' }
      end
    end
  end

  test 'submits product and enqueues product review by Pjord' do
    assert_enqueued_with(job: PjordProductReviewJob) do
      post products_path(_login_name: 'hatsuno'),
           params: { practice_id: practices(:practice6).id, product: { body: '提出物です。' }, commit: '提出する' }
    end

    assert_predicate Product.order(:created_at).last, :published_at?
  end
end
