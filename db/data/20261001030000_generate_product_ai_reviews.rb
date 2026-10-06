# frozen_string_literal: true

class GenerateProductAiReviews < ActiveRecord::Migration[8.1]
  def up
    Product.unchecked.not_wip.includes(:product_ai_review).find_each do |product|
      next if product.product_ai_review&.content.present?

      ProductAiReviewJob.perform_later(product.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
