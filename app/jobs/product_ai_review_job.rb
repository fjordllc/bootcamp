# frozen_string_literal: true

class ProductAiReviewJob < ApplicationJob
  queue_as :default

  def perform(product_id:, generation:)
    product = Product.find_by(id: product_id)
    return unless product && claim(product, generation)

    if RubyLLM.config.anthropic_api_key.blank?
      finish(product, generation, status: 'unconfigured')
      return
    end

    generate(product, generation)
  end

  private

  def claim(product, generation)
    product.with_lock do
      review = product.product_ai_review
      return false unless review&.generation == generation && review.status == 'pending' && review.current_for?(product)

      review.update!(status: 'generating')
    end
    true
  rescue ActiveRecord::RecordNotFound
    false
  end

  def generate(product, generation)
    content = ProductReviewAgent.review(product, model: product.product_ai_review.model)
    if content.is_a?(String) && content.present?
      finish(product, generation, status: 'completed', content:, generated_at: Time.current)
    else
      finish(product, generation, status: 'failed')
    end
  rescue StandardError
    # Do not expose or log provider errors: they may contain submitted text or credentials.
    retrying = executions < 3
    updated = finish(product, generation, status: retrying ? 'pending' : 'failed')
    retry_job wait: 1.minute if retrying && updated
  end

  def finish(product, generation, **attributes)
    product.with_lock do
      review = product.product_ai_review
      return false unless review&.generation == generation && review.status == 'generating'

      unless review.current_for?(product)
        review.update!(status: 'cancelled', content: nil, generated_at: nil)
        return false
      end

      review.update!(**attributes)
    end
    true
  rescue ActiveRecord::RecordNotFound
    false
  end
end
