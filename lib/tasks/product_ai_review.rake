# frozen_string_literal: true

namespace :product_ai_review do
  desc 'Queue AI reviews for unchecked submissions with blank review text'
  task backfill: :environment do
    queued = 0
    Product.unchecked.not_wip.includes(:product_ai_review).find_each do |product|
      next if product.product_ai_review&.content.present?

      ProductAiReviewJob.perform_later(product.id)
      queued += 1
    end
    puts queued
  end
end
