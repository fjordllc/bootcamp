# frozen_string_literal: true

require 'test_helper'

class GenerateProductAiReviewsTest < ActiveJob::TestCase
  test 'migration queues only unchecked non WIP products with blank review text without changing records or calling AI' do
    migration_path = Rails.root.join('db/data/20261001030000_generate_product_ai_reviews.rb')
    assert_path_exists migration_path
    require migration_path

    eligible = products(:product1, :product6, :product8, :product10)
    Product.unchecked.not_wip.where.not(id: eligible.map(&:id)).find_each do |product|
      product.create_product_ai_review!(content: '保存済み支援')
    end
    eligible[1].create_product_ai_review!(content: nil)
    eligible[2].create_product_ai_review!(content: '')
    eligible[3].create_product_ai_review!(content: " \n\t")
    models = [Product, ProductAiReview, Comment, Check, Notification]
    records_before = models.map { |model| model.order(:id).map(&:attributes) }

    ProductReviewAgent.stub(:review, ->(*) { flunk 'Migration must not call AI' }) do
      assert_enqueued_jobs eligible.size, only: ProductAiReviewJob do
        GenerateProductAiReviews.new.up
      end
    end

    eligible.each do |product|
      assert_enqueued_with(job: ProductAiReviewJob, args: [product.id])
    end
    records_after = models.map { |model| model.order(:id).map(&:attributes) }
    assert_equal records_before, records_after
  end

  test 'migration raises when enqueue returns false without changing records or calling AI' do
    require Rails.root.join('db/data/20261001030000_generate_product_ai_reviews.rb')
    models = [Product, ProductAiReview, Comment, Check, Notification]
    records_before = models.map { |model| model.order(:id).map(&:attributes) }

    ProductReviewAgent.stub(:review, ->(*) { flunk 'Migration must not call AI' }) do
      ProductAiReviewJob.stub(:perform_later, false) do
        assert_no_enqueued_jobs only: ProductAiReviewJob do
          error = assert_raises ActiveJob::EnqueueError do
            GenerateProductAiReviews.new.up
          end
          assert_equal 'Failed to enqueue product AI review', error.message
        end
      end
    end

    records_after = models.map { |model| model.order(:id).map(&:attributes) }
    assert_equal records_before, records_after
  end

  test 'migration cannot be reversed' do
    migration_path = Rails.root.join('db/data/20261001030000_generate_product_ai_reviews.rb')
    assert_path_exists migration_path
    require migration_path

    assert_raises ActiveRecord::IrreversibleMigration do
      GenerateProductAiReviews.new.down
    end
  end
end
