# frozen_string_literal: true

class ProductAiReviewJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find_by(id: product_id)
    return if product.nil? || product.wip?

    body = product.body
    practice_id = product.practice_id
    content = review(product)
    return if content.nil?

    product.with_lock do
      return if product.wip? || submission_changed?(product, body, practice_id)

      review = product.reload_product_ai_review || product.build_product_ai_review
      review.update!(content:)
    end
  rescue ActiveRecord::RecordNotFound
    # The submission may have been deleted during generation.
    nil
  end

  private

  def submission_changed?(product, body, practice_id)
    product.body != body || product.practice_id != practice_id
  end

  def review(product)
    return if RubyLLM.config.anthropic_api_key.blank?

    content = ProductReviewAgent.review(product)
    content.presence if content.is_a?(String)
  rescue StandardError
    # Provider errors may include submitted text or the private model answer.
    nil
  end
end
