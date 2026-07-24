# frozen_string_literal: true

require 'test_helper'

class Products::PjordReviewCommentTest < ActionDispatch::IntegrationTest
  test 'creates product review comment by Pjord when product is submitted' do
    Pjord::ProductReviewAgent.stub(:review_result, { body: 'レビュー本文', auto_check: false }) do
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
    Pjord::ProductReviewAgent.stub(:review_result, { body: 'レビュー本文', auto_check: false }) do
      assert_no_enqueued_jobs only: PjordProductReviewJob do
        post products_path(_login_name: 'hatsuno'),
             params: { practice_id: practices(:practice6).id, product: { body: 'WIPです。' }, commit: 'WIP' }
      end
    end
  end

  test 'does not create product review comment by Pjord when practice does not enable Pjord review' do
    practice = practices(:practice6)
    practice.update!(pjord_review: false)

    Pjord::ProductReviewAgent.stub(:review_result, ->(_product) { raise 'should not be called' }) do
      assert_no_enqueued_jobs only: PjordProductReviewJob do
        assert_no_difference -> { Comment.where(user: users(:pjord)).count } do
          post products_path(_login_name: 'hatsuno'),
               params: { practice_id: practice.id, product: { body: '提出物です。' }, commit: '提出する' }
        end
      end
    end

    product = Product.order(:created_at).last
    assert_redirected_to product_path(product)
    assert_predicate product, :published_at?
    assert_no_difference -> { product.comments.where(user: users(:pjord)).count } do
      PjordProductReviewJob.perform_now(product_id: product.id)
    end
  end

  test 'creates product review comment by Pjord when WIP product is submitted' do
    product = products(:product5)

    Pjord::ProductReviewAgent.stub(:review_result, { body: 'レビュー本文', auto_check: false }) do
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

    Pjord::ProductReviewAgent.stub(:review_result, { body: 'レビュー本文', auto_check: false }) do
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

  test 'mentor can manually create product review comment by Pjord' do
    product = products(:product8)

    Pjord::ProductReviewAgent.stub(:review_result, { body: 'コメント本文', auto_check: false }) do
      assert_no_enqueued_jobs only: PjordProductReviewJob do
        assert_difference -> { product.comments.where(user: users(:pjord)).count }, 1 do
          post review_by_pjord_product_path(product, _login_name: 'mentormentaro')
        end
      end
    end

    assert_redirected_to product_path(product)
    assert_equal 'ピヨルドがコメントしました。', flash[:notice]
    assert_equal 'コメント本文', product.comments.order(:created_at).last.description
  end

  test 'redirects with alert when Pjord product review fails' do
    product = products(:product8)

    PjordProductReviewJob.stub(:perform_now, ->(_args) { raise StandardError, 'error' }) do
      assert_no_difference 'Comment.count' do
        post review_by_pjord_product_path(product, _login_name: 'mentormentaro')
      end
    end

    assert_redirected_to product_path(product)
    assert_equal 'ピヨルドのコメントに失敗しました。時間をおいて再度お試しください。', flash[:alert]
  end

  test 'redirects with alert when Pjord product review API key is invalid' do
    product = products(:product8)

    PjordProductReviewJob.stub(:perform_now, lambda { |_args|
      raise RubyLLM::UnauthorizedError.new(nil, 'invalid x-api-key')
    }) do
      assert_no_difference 'Comment.count' do
        post review_by_pjord_product_path(product, _login_name: 'mentormentaro')
      end
    end

    assert_redirected_to product_path(product)
    assert_equal 'ピヨルドのAPIキー設定が無効です。管理者に確認してください。', flash[:alert]
  end

  test 'student cannot manually create product review comment by Pjord' do
    assert_no_enqueued_jobs only: PjordProductReviewJob do
      assert_no_difference 'Comment.count' do
        post review_by_pjord_product_path(products(:product8), _login_name: 'hatsuno')
      end
    end
  end
end
