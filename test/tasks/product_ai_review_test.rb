# frozen_string_literal: true

require 'test_helper'
require 'rake'

class ProductAiReviewTaskTest < ActiveJob::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('product_ai_review:backfill')
    Rake::Task['product_ai_review:backfill'].reenable
    clear_enqueued_jobs
  end

  test 'backfill queues only unchecked non WIP products with blank review text' do
    eligible = products(:product1, :product6, :product8, :product10)
    Product.unchecked.not_wip.where.not(id: eligible.map(&:id)).find_each do |product|
      product.create_product_ai_review!(content: '保存済み支援')
    end
    eligible[1].create_product_ai_review!(content: nil)
    eligible[2].create_product_ai_review!(content: '')
    eligible[3].create_product_ai_review!(content: " \n\t")
    products_before = Product.order(:id).map(&:attributes)
    reviews_before = ProductAiReview.order(:id).map(&:attributes)

    assert_no_difference ['Comment.count', 'Check.count', 'Notification.count', 'ProductAiReview.count'] do
      assert_enqueued_jobs eligible.size, only: ProductAiReviewJob do
        assert_output "#{eligible.size}\n" do
          Rake::Task['product_ai_review:backfill'].invoke
        end
      end
    end
    eligible.each do |product|
      assert_enqueued_with(job: ProductAiReviewJob, args: [product.id])
    end
    assert_equal products_before, Product.order(:id).map(&:attributes)
    assert_equal reviews_before, ProductAiReview.order(:id).map(&:attributes)

    eligible.each do |product|
      review = product.reload.product_ai_review || product.build_product_ai_review
      review.update!(content: '生成済み支援')
    end
    Rake::Task['product_ai_review:backfill'].reenable
    assert_no_enqueued_jobs only: ProductAiReviewJob do
      assert_output "0\n" do
        Rake::Task['product_ai_review:backfill'].invoke
      end
    end
  end
end
