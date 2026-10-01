# frozen_string_literal: true

class ProductAiReviewJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find_by(id: product_id)
    return if product.nil? || product.wip?

    body = product.body
    content = review(product)
    return if content.nil?

    product.with_lock do
      return if product.wip? || product.body != body

      review = product.reload_product_ai_review || product.build_product_ai_review
      review.update!(content:)
    end
  rescue ActiveRecord::RecordNotFound
    # The submission may have been deleted during generation.
    nil
  end

  private

  def review(product)
    return if RubyLLM.config.anthropic_api_key.blank?

    content = ProductReviewAgent.review(product)
    content.presence if content.is_a?(String)
  rescue StandardError
    # Provider errors may include submitted text or the private model answer.
    nil
  end
end
