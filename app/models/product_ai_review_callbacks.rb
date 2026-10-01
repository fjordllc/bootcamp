# frozen_string_literal: true

class ProductAiReviewCallbacks
  def after_save(product)
    return unless input_changed?(product)

    # A job may have completed since this instance cached the association.
    review = product.reload_product_ai_review
    return if product.wip? && review.nil?

    review ||= product.build_product_ai_review
    review.update!(generation: SecureRandom.uuid,
                   source_fingerprint: ProductAiReview.fingerprint_for(product),
                   status: product.wip? ? 'cancelled' : 'pending', content: nil, generated_at: nil,
                   model: ENV.fetch('PRODUCT_REVIEW_LLM_MODEL', 'claude-opus-5-5'))
  end

  def after_commit(product)
    return unless input_changed?(product)

    review = product.product_ai_review
    return unless review&.status == 'pending' && review.current_for?(product)

    ProductAiReviewJob.perform_later(product_id: product.id, generation: review.generation)
  rescue StandardError
    # Queue failure must not turn a successful submission into an error page.
    mark_enqueue_failed(product, review.generation) if review
  end

  private

  def mark_enqueue_failed(product, generation)
    product.with_lock do
      review = product.product_ai_review
      review.update!(status: 'failed') if review&.generation == generation && review.status == 'pending'
    end
  end

  def input_changed?(product)
    product.saved_change_to_id? || product.saved_change_to_body? || product.saved_change_to_wip? || product.saved_change_to_practice_id?
  end
end
